FROM alpine:3.9

RUN apk add --no-cache font-noto font-noto-extra imagemagick librsvg jq pango
RUN wget -O /usr/bin/yj \
  https://github.com/sclevine/yj/releases/download/v3.1.0/yj-linux \
  && chmod +x /usr/bin/yj
RUN cd /tmp \
  && wget \
  https://noto-website-2.storage.googleapis.com/pkgs/NotoSans-unhinted.zip \
  https://noto-website-2.storage.googleapis.com/pkgs/NotoSansCJKkr-hinted.zip \
  && mkdir -p /usr/share/fonts/noto \
  && for z in /tmp/NotoSans*.zip; do \
    unzip \
      -o \
      $z \
      "*Bold*" \
      -x "*Condensed*" \
      -x "*Mono*" \
      -d /usr/share/fonts/noto/; \
  done \
  && rm /tmp/NotoSans*.zip

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
