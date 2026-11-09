FROM node:26-slim

MAINTAINER "Rémy BRUYERE <me@remy.ovh>"

# Install custom extensions
RUN apt-get update && apt-get install -y \
    make curl wget zip git jq

# yarn is no longer packaged for Debian trixie (node:26-slim's base); install via npm instead
RUN npm install --global yarn

RUN rm -rf /var/lib/apt/lists/*
