#!/bin/sh

DESTDIR=$1
PREFIX=$2
EXECUTABLE=$3
VCPKG_INSTALLED=$4

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

# copy dependencies from the given executable or shared library
# to the matching library path, recursive
function copy_dependencies() {
    DESTDIR=$1
    PREFIX=$2
    BINARY=$3
    VCPKG_INSTALLED=$4

    # iterate over all dependencies of the binary
    for DEPENDENCY in $(readelf -d "${BINARY}" | grep "Shared library" | awk -F'[\[|\]]' '{print $2}'); do
        DEPENDENCY_PATH="${VCPKG_INSTALLED}/lib/${DEPENDENCY}"

        # check if vcpkg has the requested dependency
        if [ ! -e "${DEPENDENCY_PATH}" ]; then
            continue
        fi

        # check if the dependency is already installed
        if [ ! -e "${DESTDIR}/${PREFIX}/lib/${DEPENDENCY}" ]; then
            mkdir -p ${DESTDIR}/${PREFIX}/lib

            if [ -L "${DEPENDENCY_PATH}" ]; then
                # recreate the link in the install dir
                cp $(realpath ${DEPENDENCY_PATH}) ${DESTDIR}/${PREFIX}/lib/
            fi

            cp --no-dereference ${DEPENDENCY_PATH} ${DESTDIR}/${PREFIX}/lib/
        fi

        # copy dependencies for the library itself
        copy_dependencies "${DESTDIR}" "${PREFIX}" "${DESTDIR}/${PREFIX}/lib/${DEPENDENCY}" "${VCPKG_INSTALLED}"
    done
}

# copy dependencies for the executable
copy_dependencies "${DESTDIR}" "${PREFIX}" "${DESTDIR}/${EXECUTABLE}" "${VCPKG_INSTALLED}"
