#!/bin/sh
# Keeps each barrel's export lines sorted and unique (directives_ordering).
for f in lib/sheen.dart lib/travel.dart; do
  head=$(sed -n '1,/^library;/p' "$f")
  exports=$(grep "^export " "$f" | sort -u)
  printf '%s\n\n%s\n' "$head" "$exports" > "$f"
done
