#!/bin/bash

curl https://download.hyper.space/api/install | bash

source  /home/ubuntu/.bashrc

aios-cli start >> aios.log 2>&1 &

aios-cli models add hf:TheBloke/Mistral-7B-Instruct-v0.1-GGUF:mistral-7b-instruct-v0.1.Q4_K_S.gguf

