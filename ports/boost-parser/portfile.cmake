# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/parser
    REF boost-${VERSION}
    SHA512 b558f8dce66aa073f23672907cd39b8ef8035c4d8cae631e72255dd2d1181a6e65e8347d9204f1e2053d88b8700e181ce3691fbb3c840621545f554fda931b10
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
