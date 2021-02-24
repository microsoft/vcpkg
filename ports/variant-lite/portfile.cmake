vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/variant-lite
    REF v1.2.2
    SHA512 f0a0760b858d5fdd3cbd6be29e64fdca69222c4e3f6f4f856fa99e7352ede817648c6d698ebde25dec10bf99fc304b1b5ce232c5ffd4fab12aaf444b68c04f02
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DVARIANT_LITE_OPT_BUILD_TESTS=OFF
        -DVARIANT_LITE_OPT_BUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(
    CONFIG_PATH lib/cmake/${PORT}
)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug
    ${CURRENT_PACKAGES_DIR}/lib
)

file(INSTALL
    ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright
)
