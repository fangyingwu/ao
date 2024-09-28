#!/bin/bash

curl https://download.hyper.space/api/install | bash

source  /home/ubuntu/.bashrc

nohup ./home/ubuntu/.aios/aios-cli start >> aios.log 2>&1 &

sleep 5

/home/ubuntu/.aios/aios-cli models add hf:TheBloke/Mistral-7B-Instruct-v0.1-GGUF:mistral-7b-instruct-v0.1.Q4_K_S.gguf

/home/ubuntu/.aios/aios-cli hive login

/home/ubuntu/.aios/aios-cli hive import-keys .config/hyperspace/key.pem

/home/ubuntu/.aios/aios-cli hive login

/home/ubuntu/.aios/aios-cli hive connect


