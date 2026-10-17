#!/bin/sh
set -eu
# Run from the repository root. No project source is modified.
work=$(mktemp -d)
work=$(cd "$work" && pwd -P)
trap 'rm -rf "$work"' EXIT
go build -o "$work/weave" ./cmd/weave
"$work/weave" assess --root examples/project --out "$work/assessment"
"$work/weave" extract --root examples/project --out "$work/extracted"
"$work/weave" build --root "$work/extracted/sources" --recipe examples/review.recipe.json --out "$work/review"
"$work/weave" build --root "$work/extracted/sources" --recipe examples/test.recipe.json --out "$work/test"
"$work/weave" build --root "$work/extracted/sources" --recipe examples/test.recipe.json --out "$work/repeat"
cmp "$work/test/bundle.json" "$work/repeat/bundle.json"
"$work/weave" diff --before "$work/review" --after "$work/test" --out "$work/comparison"
echo 'Synthetic flow passed: two assignments, deterministic repeat, comparison.'
