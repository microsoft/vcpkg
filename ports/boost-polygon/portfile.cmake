# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/polygon
    REF boost-${VERSION}
    SHA512 bd9e19d941f37d89a9aebde23ab72d024d0ec307449c77e1aded4f643d92e3d5fc32d8f3160bd78c276004003e3281d4e9163759b3f78e5593a584bd382b0482
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
