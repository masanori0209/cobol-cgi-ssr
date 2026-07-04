#!/bin/bash
set -eu
cd "$(dirname "$0")/.."
mkdir -p data/sessions
if [ ! -f data/session.seq ]; then
  echo "0" > data/session.seq
fi
cobc -Wall -x -free \
  -I src/copy \
  -I src \
  src/ssr.cbl \
  src/ssrtemplate.cbl \
  src/cgihtmlhdr.cbl \
  src/cgilib.cbl \
  src/navbuild.cbl \
  src/postsdata.cbl \
  src/postlistfill.cbl \
  src/renderpage.cbl \
  src/controllers/*.cbl \
  -o ssr.cgi
echo "built ssr.cgi"
