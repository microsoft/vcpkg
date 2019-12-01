#!/usr/bin/bash
set -e
export PATH=/usr/bin:$PATH

#SOURCE_PATH="`cygpath "$1"`"
#CURRENT_PACKAGES_DIR="`cygpath "$2"`"
SOURCE_PATH="$1"
CURRENT_PACKAGES_DIR="$2"

echo "CURRENT_PACKAGES_DIR=${CURRENT_PACKAGES_DIR}"

pushd ${SOURCE_PATH}
make PREFIX=${CURRENT_PACKAGES_DIR}
make install PREFIX=${CURRENT_PACKAGES_DIR}
mkdir -p /usr/lib/pkgconfig
cp ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/ffnvcodec.pc /usr/lib/pkgconfig
popd
