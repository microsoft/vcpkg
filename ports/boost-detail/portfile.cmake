# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/detail
    REF boost-${VERSION}
    SHA512 efc43b2425ed37eec2fdc84f740bbc8c56a34f9fad94d5d24adce7916102169ea454857f47fa36bb8ff68ac5f5bc8fa112069fcee3d33ef51f9977111e372d10
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
