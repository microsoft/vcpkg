vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LuminoEngine/Lumino
    REF "v${VERSION}"
    SHA512 f43e48b36a48b5fcce4767de087f9953c905ac0af5522042a93c39ec75e4c9489b8910bc5b2f6fd129ce197309377a14b6eb9177a6ea9db4f5c2e7d1b13a137d
    HEAD_REF main
    PATCHES
        fix-cmake-config.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES 
        engine  LUMINO_BUILD_ENGINE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLUMINO_BUILD_EXAMPLES=OFF
        -DLN_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/lumino)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

