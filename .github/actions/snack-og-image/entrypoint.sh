#!/bin/ash
set -e
mkdir -p static/og
yj -t < config.toml | jq '.languages' > /tmp/languages.json
for language in $(jq -r '.|keys|join("\n")' /tmp/languages.json); do
  jq -r ".$language" /tmp/languages.json > "/tmp/$language.json"
  if jq -e '.ianaSubtag' "/tmp/$language.json" > /dev/null; then
    text="$(jq -r '.title' "/tmp/$language.json")"
    iana="$(jq -r '.ianaSubtag' "/tmp/$language.json")"
    pango-view \
      -t "$text" \
      --no-display \
      --font='Noto Sans bold 32px' \
      --language "$iana" \
      --hinting=full \
      --margin="50 50 65 90" \
      --pixels \
      -o "/tmp/text-$language.png"
    width="$(identify -format '%w' "/tmp/text-$language.png")"
    right=$((width-50))
    convert "/tmp/text-$language.png" \
      -fill none \
      -stroke black \
      -strokewidth 5 \
      -draw "line 50,100 $right,100" \
      "/tmp/text-$language.png"
    composite \
      -compose multiply \
      -geometry +50+60 \
      -density 125 \
      "themes/hugo-planetarium/static/logo.svg" \
      "/tmp/text-$language.png" \
      "static/og/$language.png"
  fi
done
