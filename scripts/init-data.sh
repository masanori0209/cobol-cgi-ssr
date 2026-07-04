#!/bin/bash
set -eu
mkdir -p data/sessions
if [ ! -f data/session.seq ]; then
  echo "0" > data/session.seq
fi
