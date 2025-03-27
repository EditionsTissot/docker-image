FROM alpine:3.16

# Install custom extensions
RUN apk upgrade --update && \
    apk add --no-cache git openssh ansible rsync

RUN rm -rf /var/cache/apk/*
