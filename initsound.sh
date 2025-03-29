#!/bin/bash

# 1️⃣ 安装依赖
sudo DEBIAN_FRONTEND=noninteractive apt install -y pkg-config libssl-dev expect
sudo NEEDRESTART_MODE=a apt update

# 2️⃣ 安装 Rust & Cargo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# 3️⃣ 配置环境变量
export PATH=$HOME/.cargo/bin:$PATH
export PATH=/root/.cargo/bin:$PATH
echo 'export PATH=$HOME/.cargo/bin:$PATH' >> ~/.bashrc
echo 'export PATH=/root/.cargo/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# 4️⃣ 安装 soundnessup
curl -sSL https://raw.githubusercontent.com/soundnesslabs/soundness-layer/main/soundnessup/install | bash
bash -i -c "soundnessup install"
bash -i -c "soundnessup update"

# 5️⃣ 运行 expect
script -q -c "expect <<EOF
spawn bash -i -c \"soundness-cli generate-key --name my-key\"
expect \"Enter password for secret key:\"
send \"123456\r\"
expect \"Confirm password:\"
send \"123456\r\"
expect eof
EOF
"
