FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Download and install Portainer
RUN wget https://github.com/portainer/portainer/releases/download/2.19.4/portainer-2.19.4-linux-amd64.tar.gz && \
    tar -xzf portainer-2.19.4-linux-amd64.tar.gz && \
    mv portainer /usr/local/bin/ && \
    rm portainer-2.19.4-linux-amd64.tar.gz && \
    mkdir -p /data

EXPOSE 9443

CMD ["/usr/local/bin/portainer", "--data", "/data", "--bind", ":9443"]
