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
      --font='Noto Sans bold 40px' \
      --language "$iana" \
      --hinting=full \
      --pixels \
      -o "/tmp/text-$language.png"
    text_width="$(identify -format '%w' "/tmp/text-$language.png")"
    text_height="$(identify -format '%h' "/tmp/text-$language.png")"
    logo_width=45
    logo_margin=5
    rsvg-convert "themes/hugo-planetarium/static/logo.svg" \
      --format png \
      --width "$logo_width" \
      --keep-aspect-ratio \
      --output /tmp/logo.png
    logo_height="$(identify -format '%h' "/tmp/logo.png")"
    line_width=6
    # canvas
    convert \
      -size "$((text_width+logo_width))x$((text_height+line_width))" \
      xc:white \
      "static/og/$language.png"
    # text
    composite \
      -compose multiply \
      "/tmp/text-$language.png" \
      -geometry "+$((logo_width+logo_margin))+0" \
      "static/og/$language.png" \
      "static/og/$language.png"
    # logo
    composite \
      -compose multiply \
      "/tmp/logo.png" \
      -geometry "+0+$(((text_height-logo_height)/2+3))" \
      "static/og/$language.png" \
      "static/og/$language.png"
    # underline
    line="0,$text_height $((text_width+logo_width+logo_margin)),$text_height"
    convert "static/og/$language.png" \
      -fill none \
      -stroke black \
      -strokewidth "$line_width" \
      -draw "line $line" \
      "static/og/$language.png"
    width="$(identify -format '%w' "static/og/$language.png")"
    height="$(identify -format '%h' "static/og/$language.png")"
    # margin
    convert "static/og/$language.png" \
        -gravity north \
        -extent "${width}x$((height+10))" \
        -bordercolor white \
        -border 100x100 \
      "static/og/$language.png"
  fi
done
