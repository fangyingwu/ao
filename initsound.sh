#!/bin/bash

sudo DEBIAN_FRONTEND=noninteractive apt install -y pkg-config libssl-dev

sudo DEBIAN_FRONTEND=noninteractive apt install -y expect

sudo NEEDRESTART_MODE=a apt update

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
source $HOME/.cargo/env && rustc --version && cargo --version && echo 'source $HOME/.cargo/env' >> ~/.bashrc && source ~/.bashrc && \
curl -sSL https://raw.githubusercontent.com/soundnesslabs/soundness-layer/main/soundnessup/install | bash && \
source ~/.bashrc && soundnessup install && \
soundnessup update

expect <<EOF
spawn soundness-cli generate-key --name my-key
expect "Enter password for secret key:"
send "123456\r"
expect "Confirm password:"
send "123456\r"
expect eof
EOF

