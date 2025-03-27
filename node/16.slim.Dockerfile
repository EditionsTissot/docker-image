FROM node:16-slim

# Install custom extensions
RUN apt-get update && apt-get install -y \
    make curl yarn wget zip git jq


RUN rm -rf /var/lib/apt/lists/*
