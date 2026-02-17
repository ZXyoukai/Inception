FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    redis-server \
    && rm -rf /var/lib/apt/lists/*

# Configure Redis to accept connections from other containers
RUN sed -i 's/bind 127.0.0.1 ::1/bind 0.0.0.0/g' /etc/redis/redis.conf

EXPOSE 6379

CMD ["redis-server", "--protected-mode", "yes"]
