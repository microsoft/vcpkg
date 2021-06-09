vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO syoyo/tinyexr
    REF v1.0.0
    SHA512 5c7dc7201ea57d98505ece22161dc72c284b3db1a7993e46317254dfc42b0f0e76a59227c3cc601fd8a347f0d3aedf2e5f7d7eb9434068face94f503b94711fd
    HEAD_REF master
    PATCHES
        fixtargets.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DTINYEXR_BUILD_SAMPLE=OFF
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
