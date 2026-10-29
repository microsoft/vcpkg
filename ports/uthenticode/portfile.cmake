vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO trailofbits/uthenticode
    REF "v${VERSION}"
    SHA512 447c1edd2fcd7ba6e960ef5caf32f2b0b9b8bd6b83e5ec02313ff6ae2063bc37a4c250cfdcd57d0717ba93f783c4c8390280edd54a2f63f53c4185faeab6610a
    HEAD_REF master
    PATCHES
        openssl.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/uthenticode)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
