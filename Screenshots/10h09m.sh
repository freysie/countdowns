#!/bin/sh

targets=(
  "Detail"
  "List"
)

for target in ${targets[@]}; do
  file="$target@watchOS.png"
  convert -composite -gravity NorthEast $file "10h09m@45mm.png" $file
  echo "$file set to 10:09."
done
