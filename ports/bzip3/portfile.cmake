vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO iczelia/bzip3
    REF "${VERSION}"
    SHA512 159144b14f1e118e736bbef21ccb3cbf350d863719508217878d22835885912e8cd898704ced76a3ac5cee91d90e75bc0a81d9e64bf7cd6f4e5330b5a3564e5e
    HEAD_REF master
    PATCHES
        disable-man.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        tools    BZIP3_BUILD_APPS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/bzip3)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/3rdparty/libsais-LICENSE"
)
