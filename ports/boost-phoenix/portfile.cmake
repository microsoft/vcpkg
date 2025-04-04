# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/phoenix
    REF boost-${VERSION}
    SHA512 542352c81e055381b198e5bf8eba68fa9b2435050ef8f290ce906ab7059d5bb8a78860a6a2353c65734016fef8f310c06a402bbfbb94c686fb4cfb4117d4bd56
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
