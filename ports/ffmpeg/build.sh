#!/usr/bin/bash
set -e
export PATH=/usr/bin:$PATH
export PKG_CONFIG_PATH="`cygpath -p ${PKG_CONFIG_PATH}`"
# Export HTTP(S)_PROXY as http(s)_proxy:
if [ "$HTTP_PROXY" ]; then
    export http_proxy=$HTTP_PROXY
fi
if [ "$HTTPS_PROXY" ]; then
    export https_proxy=$HTTPS_PROXY
fi

PATH_TO_BUILD_DIR="`cygpath "$1"`"
PATH_TO_SRC_DIR="`cygpath "$2"`"
PATH_TO_PACKAGE_DIR="`cygpath "$3"`"
# Note: $4 is extra configure options

cd "$PATH_TO_BUILD_DIR"
echo "=== CONFIGURING ==="
"$PATH_TO_SRC_DIR/configure" --toolchain=msvc "--prefix=$PATH_TO_PACKAGE_DIR" $4
echo "=== BUILDING ==="
make -j6
echo "=== INSTALLING ==="
make install
