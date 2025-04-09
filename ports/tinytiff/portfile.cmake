vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        winapi      TinyTIFF_USE_WINAPI_FOR_FILEIO
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jkriege2/TinyTIFF
    REF ${VERSION}
    SHA512 9a6a00a1278e7040bf3057f069e6d4f106a15982c78c84112edfdbe8ca9a28d849fc63636d8011696dbf4059c5d9b205743fd77ece859d08b9dd33945835be54
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DTinyTIFF_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/TinyTIFF DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/TinyTIFFXX PACKAGE_NAME tinytiffxx)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
