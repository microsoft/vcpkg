vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO P-H-C/phc-winner-argon2
    REF 20190702
    SHA512 0a4cb89e8e63399f7df069e2862ccd05308b7652bf4ab74372842f66bcc60776399e0eaf979a7b7e31436b5e6913fe5b0a6949549d8c82ebd06e0629b106e85f
    HEAD_REF master
    PATCHES
        visibility.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION  "${SOURCE_PATH}")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        hwopt     OPTIMIZATIONS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DARGON2_SKIP_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(TOOL_NAMES argon2 AUTO_CLEAN)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
