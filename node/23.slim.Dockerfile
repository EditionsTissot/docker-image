FROM node:23-slim

MAINTAINER "Rémy BRUYERE <me@remy.ovh>"

# Install custom extensions
RUN apt-get update && apt-get install -y \
    make curl yarn wget zip git jq


RUN rm -rf /var/lib/apt/lists/*
