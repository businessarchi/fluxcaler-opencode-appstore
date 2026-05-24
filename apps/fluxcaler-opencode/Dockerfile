FROM node:22-alpine

RUN apk add --no-cache curl bash tini

RUN npm install -g @askalf/dario opencode-ai \
    && npm cache clean --force

WORKDIR /root

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 4096

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
