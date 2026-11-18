FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    verilator \
    yosys \
    graphviz \
    xdot \
    gtkwave \
    make \
    git \
    build-essential \
    dbus-x11 \
    adwaita-icon-theme \
    && rm -rf /var/lib/apt/lists/*

# Colored terminal text. Hostname is fixed to "rtl-lab" in the prompt, because the
# container hostname now follows the host (needed for X authentication).
RUN printf '%s\n' \
  'PS1="\[\033[1;35m\]\u@rtl-lab\[\033[0m\] \[\033[1;32m\]\w\[\033[0m\] \[\033[1;37m\]\$\[\033[0m\] "' \
  > /etc/sv-prompt.sh

WORKDIR /workspace
