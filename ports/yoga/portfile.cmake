vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/yoga
    REF "v${VERSION}"
    SHA512 c17b03057dd8614099d6c1de14930eed86e0e379789bd6f57d58536e4bd53002caea23e537f817ca47644f75ca3337882e885a538f07e5f0d63968775ae564ae
    HEAD_REF master
    PATCHES
        disable_tests.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
