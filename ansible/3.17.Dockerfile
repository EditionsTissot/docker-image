FROM alpine:3.17

# Install custom extensions
RUN apk upgrade --update && \
    apk add --no-cache git openssh ansible rsync

RUN rm -rf /var/cache/apk/*
