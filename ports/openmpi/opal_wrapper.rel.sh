#!/bin/bash

DIR="$( cd "$( dirname "$0" )" && pwd )"
export OPAL_PREFIX="$( cd "$DIR/../../.." && pwd )"
exec -a "$0" "$DIR/opal_wrapper_real" "$@"
