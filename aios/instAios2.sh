#!/bin/bash

curl https://download.hyper.space/api/install | bash

source  .bashrc

nohup aios-cli start >> aios.log 2>&1 &

sleep 5

aios-cli models add hf:TheBloke/Mistral-7B-Instruct-v0.1-GGUF:mistral-7b-instruct-v0.1.Q4_K_S.gguf

aios-cli hive login

aios-cli hive import-keys .config/hyperspace/key.pem

aios-cli hive login

aios-cli hive connect


