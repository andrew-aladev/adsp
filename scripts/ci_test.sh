#!/usr/bin/env bash
set -e

DIR=$(dirname "${BASH_SOURCE[0]}")
cd "$DIR"

cd ".."

ROOT_DIR=$(pwd)

/usr/bin/env bash -cl "\
  cd \"$ROOT_DIR\" && \
  gem install bundler --force && \
  bundle install && \
  bundle exec rake \
"
