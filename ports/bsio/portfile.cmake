#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArkNX/bsio
    REF v1.0.0
    SHA512 28b895b823d84203f4cec531ddd5bb49dc915e9a4eb26e064834d1e999b98e512b37d361e59029eb6d7e44fe99ba81f9c5729f119eab7eb928de1a1374f0b7df
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Dbsio_BUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
