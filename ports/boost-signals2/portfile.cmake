# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/signals2
    REF boost-${VERSION}
    SHA512 80dd512c82a6d9b5784dbe95ee4d1cb859980699264d99abb7748a3400e01486f83fb32c628c1ac40e30b32e538af969be60ee0c345d766357de7f93984b4265
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
