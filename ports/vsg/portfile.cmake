vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vsg-dev/VulkanSceneGraph
    REF "v${VERSION}"
    SHA512 eb32cc1418bbfd0907e7bc09080001b47f5c39a44b2693a2e3127a928d78a9e80ac4356b63fe4cd8bfb16f4bf829ea56eaaa0e878380fbfe06268962331cd86b
    HEAD_REF master
)

# added -DGLSLANG_MIN_VERSION=15 to sync with vcpkg version of glslang
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGLSLANG_MIN_VERSION=
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "vsg" CONFIG_PATH "lib/cmake/vsg")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
