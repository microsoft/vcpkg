# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/vmd
    REF boost-${VERSION}
    SHA512 14b3a7ea2f2cc36d9a0bf4d7c4436e13449608d08b98bccaa4dafbd65487824e28f67d2e918d2f42362ec2c242dc6003c888a3adb48cc3f9e774060e3fc2094a
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
