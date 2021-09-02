#!/bin/sh

DESTDIR=$1
PREFIX=$2
EXECUTABLE=$3
VCPKG_INSTALLED=$(dirname $4) # vcpkg has some weird "bin" suffix that may not even exist!

# if the executable is not an absolute path
# we need to prefix the prefix directory
case "${EXECUTABLE}" in
    /*)
        # nothing to be done, but we need to catch
        # this so it doesn't go to the default case
        ;;
    *)
        # not an absolute path, so it should
        # fall under prefix
        EXECUTABLE="${PREFIX}/${EXECUTABLE}"
        ;;
esac

# iterate over all dependencies of the binary
for DEPENDENCY in $(readelf -d "${DESTDIR}/${EXECUTABLE}" | grep "Shared library" | awk -F'[\[|\]]' '{print $2}'); do
    DEPENDENCY_PATH="${VCPKG_INSTALLED}/lib/${DEPENDENCY}"

    # check if vcpkg has the requested dependency
    if [ ! -e "${DEPENDENCY_PATH}" ]; then
        continue
    fi

    # check if the dependency is already installed
    if [ -e "${DESTDIR}/${PREFIX}/lib/${DEPENDENCY}" ]; then
        continue
    fi

    echo "Installing vcpkg-provided dependency: ${DEPENDENCY_PATH}" >> /tmp/vcpkg.fixup
    mkdir -p ${DESTDIR}/${PREFIX}/lib

    if [ -L "${DEPENDENCY_PATH}" ]; then
        # recreate the link in the install dir
        cp $(realpath ${DEPENDENCY_PATH}) ${DESTDIR}/${PREFIX}/lib/
    fi

    cp --no-dereference ${DEPENDENCY_PATH} ${DESTDIR}/${PREFIX}/lib/
done
