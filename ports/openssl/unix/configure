#!/usr/bin/env bash

set -e

declare -a OUT_OPTIONS

INTERPRETER=perl

LAST_SEEN=
COPY_OPTIONS=no
for OPTION; do
    case "${OPTION},${COPY_OPTIONS}" in
    */Configure,no)
        OUT_OPTIONS+=("${OPTION}")
        INTERPRETER="${LAST_SEEN}"
        COPY_OPTIONS=yes
        ;;
    --prefix=*|--openssldir=*|--libdir=*|--cross-compile-prefix=*|--debug,*)
        OUT_OPTIONS+=("${OPTION}")
        ;;
    -*|*=*)
        ;;
    *,yes)
        OUT_OPTIONS+=("${OPTION}")
        ;;
    esac
    LAST_SEEN="${OPTION}"
done

set -x
"${INTERPRETER}" ${OUT_OPTIONS[@]}
