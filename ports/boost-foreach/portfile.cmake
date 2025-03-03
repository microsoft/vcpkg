# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/foreach
    REF boost-${VERSION}
    SHA512 92acc6bc45239700f73ba0145c9f5b921e6d58d384ebcb6d6f2462f2e630d80b0041834b86cf51506721cafc106b53fbf3fffac895919f57f4d6047afdcef222
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
