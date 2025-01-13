#!/bin/bash

set -e

source /opt/activate.sh

# created by docker build
/opt/deps/install-deps.sh

exec "$@"
