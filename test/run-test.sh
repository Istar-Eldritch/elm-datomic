#!/bin/sh

set -e

cd "$(dirname "$0")"

mkdir -p build/

elm-make --yes --output build/test.js Main.elm
echo "Elm.worker(Elm.Main);" >> build/test.js
node build/test.js
