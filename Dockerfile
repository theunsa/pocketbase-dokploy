FROM alpine:latest

ARG PB_VERSION=0.30.0

RUN apk add --no-cache \
    unzip \
    ca-certificates \
    rclone

# download and unzip PocketBase
ADD https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip /tmp/pb.zip
RUN unzip /tmp/pb.zip -d /pb/

# Copy hooks (deployed fresh with each build)
# Uncomment if you have pb_hooks in your repo
# COPY ./pb_hooks /pb/pb_hooks

# Copy scripts
COPY entrypoint.sh /entrypoint.sh
COPY backup-r2.sh /usr/local/bin/backup-r2.sh
RUN chmod +x /entrypoint.sh /usr/local/bin/backup-r2.sh

EXPOSE 8090

# start PocketBase
ENTRYPOINT ["/entrypoint.sh"]
