# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/smart_ptr
    REF boost-${VERSION}
    SHA512 5b56c43298cdf3dd636e68276954075a3bae9a1fd5736039b779935f106a252ea9e979e12362b89903375ad1de0078c9fa5c81779ffb91d8453e4e02d711e17e
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
