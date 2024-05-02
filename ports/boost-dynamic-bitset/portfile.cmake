# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/dynamic_bitset
    REF boost-${VERSION}
    SHA512 76229a33e6e659fd0ae0d32f34df0c793da203830f58c3e0a89ec4eeaf5aba4bacbc516ade9860005f74907e42ddb1995a82459e528bd7d3f42fd08c49abb63a
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
