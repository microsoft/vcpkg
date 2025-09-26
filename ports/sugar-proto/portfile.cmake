vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO illegal-instruction-co/sugar-proto
    REF v1.0.0
    SHA512 eb36ed530bf7b78049489857785e310f8168a77506eb9f7cc53a3ca4b20f8b6c74dd4ddba2f25722489c7f8e008b6f2fe93f96aa7dc024b1f666a7ce7a0871a4
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/sugar-proto)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_copy_pdbs()
