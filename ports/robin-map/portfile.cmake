vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tessil/robin-map
    REF v0.6.3
    SHA512 485557f300d33bda62bb8accdf246819ee8ffe956bc022e7ddca54ff6ad1a9fdb8db8d80690add3ef238e834d1eb8e2905920cb0a0674e7df010f6946d01297b
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/tsl-robin-map)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
