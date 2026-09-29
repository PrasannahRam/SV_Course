FROM ubuntu:24.04

RUN apt update && \
    apt install -y \
    verilator \
    gtkwave \
    make \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
