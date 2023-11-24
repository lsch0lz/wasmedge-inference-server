FROM rust:latest

USER root

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git && \
    apt-get install -y curl && \
    apt-get install -y python3

EXPOSE 8080

RUN curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install.sh | bash

# Source the environment and make the command available for subsequent commands
RUN echo 'export PATH=$PATH:$HOME/.wasmedge' >> $HOME/.bashrc
RUN echo 'source $HOME/.wasmedge/env' >> $HOME/.bashrc

# Activate the changes in the current shell
SHELL ["/bin/bash", "--login", "-c"]

RUN wasmedge --dir .:. --nn-preload default:GGML:AUTO:llama-2-7b-chat.Q5_K_M.gguf llama-api-server.wasm -p llama-2-chat

RUN curl -LO https://huggingface.co/second-state/Llama-2-7B-Chat-GGUF/resolve/main/llama-2-7b-chat.Q5_K_M.gguf

RUN wasmedge --dir .:. --nn-preload default:GGML:AUTO:llama-2-7b-chat.Q5_K_M.gguf llama-api-server.wasm -p llama-2-chat

