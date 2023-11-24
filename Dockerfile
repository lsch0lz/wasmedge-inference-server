FROM rust:latest

USER root

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git && \
    apt-get install -y curl && \
    apt-get install -y python3

EXPOSE 8080

RUN rustup target add wasm32-wasi

# Install WasmEdge
RUN curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install.sh | bash -s -- --plugins wasmedge_rustls wasi_nn-ggml


ENV PATH="/root/.wasmedge:$PATH"
ENV LD_LIBRARY_PATH="/root/.wasmedge:$LD_LIBRARY_PATH"

# Clone the repository
RUN git clone https://github.com/second-state/llama-utils.git

WORKDIR /llama-utils/api-server

# Build the project
RUN cargo build -p llama-api-server --target wasm32-wasi --release

# Download the model
RUN curl -LO https://huggingface.co/second-state/Llama-2-7B-Chat-GGUF/resolve/main/llama-2-7b-chat.Q5_K_M.gguf

# Run the WasmEdge command
RUN . $HOME/.wasmedge/env && wasmedge --dir .:. --nn-preload default:GGML:AUTO:llama-2-7b-chat.Q5_K_M.gguf llama-api-server.wasm -p llama-2-chat
