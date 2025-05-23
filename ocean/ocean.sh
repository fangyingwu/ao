#!/usr/bin/env bash
# 验证十六进制私钥格式
validate_hex() {
  if [[ ! "$1" =~ ^0x[0-9a-fA-F]{64}$ ]]; then
    echo "私钥格式错误，退出..."
    exit 1
  fi
}

# 验证端口号是否有效
validate_port() {
  if [[ ! "$1" =~ ^[0-9]+$ ]] || [ "$1" -le 1024 ] || [ "$1" -ge 65535 ]; then
    echo "端口号无效，必须介于 1024 和 65535 之间。"
    exit 1
  fi
}

# 验证输入是否为有效的 IPv4 地址或 FQDN
validate_ip_or_fqdn() {
  local input=$1
  if [[ "$input" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || [[ "$input" =~ ^[a-zA-Z0-9.-]+$ ]]; then
    return 0
  else
    echo "输入无效，必须是有效的 IPv4 地址或 FQDN。"
    return 1
  fi
}

# 从私钥生成地址
generate_address_from_private_key() {
  local private_key=$1
  private_key=${private_key#0x}  # 去掉 '0x' 前缀
  echo -n "$private_key" > /tmp/private_key_file

  docker_output=$(docker run --rm -v /tmp/private_key_file:/tmp/private_key_file ethereum/client-go:latest account import --password /dev/null /tmp/private_key_file 2>&1)

  rm /tmp/private_key_file

  address=$(echo "$docker_output" | grep -oP '(?<=Address: \{)[a-fA-F0-9]+(?=\})')

  if [ -z "$address" ]; then
    echo "无法从私钥生成地址。"
    return 1
  fi

  echo "$address"
}

# 获取公网 IP 地址
get_public_ip() {
  curl -s https://api.ipify.org
}

# 安装 Docker 和 Docker Compose
install_docker_and_compose() {
  echo "正在安装 Docker 和 Docker Compose..."

  sudo apt update & sudo apt update -y
  sudo apt install curl -y
  sudo apt install docker.io -y && \ docker --version
   sudo apt install docker-compose -y && docker-compose -version
  sudo usermod -aG docker $(whoami)
  sudo newgrp docker

  echo "Docker 和 Docker Compose 安装完成！"
}

# 安装节点
install_nodes() {
  # 检查 Docker 和 Docker Compose 是否已安装，如果未安装则安装
  if ! command -v docker &> /dev/null || ! command -v docker-compose &> /dev/null; then
    install_docker_and_compose
  fi

  read -p "输入节点的起始索引: " START_INDEX
  read -p "输入节点的结束索引: " END_INDEX
  BASE_DIR="/root/ocean"

  if ! mkdir -p "$BASE_DIR"; then
    echo "无法创建基础目录: $BASE_DIR"
    exit 1
  fi

  P2P_ANNOUNCE_ADDRESS=$(get_public_ip)
  echo "检测到的公网 IP 地址: $P2P_ANNOUNCE_ADDRESS"
  read -p "使用此 IP 作为 P2P_ANNOUNCE_ADDRESS? (y/n): " use_detected_ip
  if [[ $use_detected_ip != "y" ]]; then
    read -p "提供节点可访问的公网 IPv4 地址或 FQDN: " P2P_ANNOUNCE_ADDRESS
  fi
  validate_ip_or_fqdn "$P2P_ANNOUNCE_ADDRESS"

  BASE_HTTP_PORT=$((10000 + (START_INDEX - 1) * 6))
  PORT_INCREMENT=6

  install_single_node() {
    local i=$1
    local NODE_DIR="${BASE_DIR}/node${i}"
    mkdir -p "$NODE_DIR"
    echo "在 $NODE_DIR 中设置节点 $i"

    read -p "节点 $i 是否手动输入私钥？ (y/n): " input_key
    if [[ "$input_key" == "y" ]]; then
      read -p "输入节点 $i 的私钥 (以 0x 开头): " PRIVATE_KEY
      validate_hex "$PRIVATE_KEY"
      echo "$PRIVATE_KEY" > "${NODE_DIR}/private_key"
    else
      PRIVATE_KEY=$(openssl rand -hex 32)
      PRIVATE_KEY="0x$PRIVATE_KEY"
      echo "$PRIVATE_KEY" > "${NODE_DIR}/private_key"
      echo "为节点 $i 生成的私钥: $PRIVATE_KEY"
    fi

    validate_hex "$PRIVATE_KEY"
    ADMIN_ADDRESS=$(generate_address_from_private_key "$PRIVATE_KEY")
    echo "为节点 $i 生成的管理员地址: 0x$ADMIN_ADDRESS"

    HTTP_PORT=$((BASE_HTTP_PORT + (i-START_INDEX)*PORT_INCREMENT))
    P2P_TCP_PORT=$((HTTP_PORT + 1))
    P2P_WS_PORT=$((HTTP_PORT + 2))
    P2P_IPV6_TCP_PORT=$((HTTP_PORT + 3))
    P2P_IPV6_WS_PORT=$((HTTP_PORT + 4))
    TYPESENSE_PORT=$((HTTP_PORT + 5))

    validate_port "$HTTP_PORT"
    validate_port "$P2P_TCP_PORT"
    validate_port "$P2P_WS_PORT"
    validate_port "$P2P_IPV6_TCP_PORT"
    validate_port "$P2P_IPV6_WS_PORT"
    validate_port "$TYPESENSE_PORT"

    if [[ "$P2P_ANNOUNCE_ADDRESS" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      P2P_ANNOUNCE_ADDRESSES='["/ip4/'$P2P_ANNOUNCE_ADDRESS'/tcp/'$P2P_TCP_PORT'", "/ip4/'$P2P_ANNOUNCE_ADDRESS'/ws/tcp/'$P2P_WS_PORT'"]'
    elif [[ "$P2P_ANNOUNCE_ADDRESS" =~ ^[a-zA-Z0-9.-]+$ ]]; then
      P2P_ANNOUNCE_ADDRESSES='["/dns4/'$P2P_ANNOUNCE_ADDRESS'/tcp/'$P2P_TCP_PORT'", "/dns4/'$P2P_ANNOUNCE_ADDRESS'/ws/tcp/'$P2P_WS_PORT'"]'
    else
      P2P_ANNOUNCE_ADDRESSES=''
      echo "未提供输入，其他节点可能无法访问 Ocean 节点。"
    fi

    cat <<EOF > "${NODE_DIR}/docker-compose.yml"
# 这里是 docker-compose.yml 内容
EOF

    echo "节点 $i 的 Docker Compose 文件已生成，位于 ${NODE_DIR}/docker-compose.yml"
    echo "正在启动节点 $i..."
    (cd "$NODE_DIR" && docker-compose up -d)

    if [ $? -eq 0 ]; then
      echo "节点 $i 启动成功。"
    else
      echo "无法启动节点 $i。"
      return 1
    fi
  }

  for ((i=START_INDEX; i<=END_INDEX; i++)); do
    install_single_node $i
  done
}

# 卸载节点
uninstall_nodes() {
  read -p "输入节点的起始索引: " START_INDEX
  read -p "输入节点的结束索引: " END_INDEX
  BASE_DIR="/root/ocean"

  uninstall_single_node() {
    local i=$1
    local NODE_DIR="${BASE_DIR}/node${i}"
    if [ -d "$NODE_DIR" ]; then
      echo "正在停止并移除节点 $i 的容器..."
      (cd "$NODE_DIR" && docker-compose down -v)
      echo "正在移除节点目录..."
      rm -rf "$NODE_DIR"
      echo "节点 $i 已卸载。"
    else
      echo "未找到节点 $i 的目录。跳过..."
    fi
  }

  for ((i=START_INDEX; i<=END_INDEX; i++)); do
    uninstall_single_node $i
  done

  echo "卸载完成。"
}

# 主脚本
echo "Ocean 节点管理脚本"
echo "1. 安装 Ocean 节点"
echo "2. 卸载 Ocean 节点"
read -p "输入你的选择 (1 或 2): " choice

case $choice in
  1)
    install_nodes
    ;;
  2)
    uninstall_nodes
    ;;
  *)
    echo "无效的选择。退出。"
    exit 1
    ;;
esac
