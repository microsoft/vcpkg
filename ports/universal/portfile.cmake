set(VCPKG_BUILD_TYPE release)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stillwater-sc/universal
    REF "v${VERSION}"
    SHA512 b4015a3c68aa17417f39867de0f036e7706442f9d7cdc470b6f237b98e341d6875a73fd22579713cf28976b7dd6bbfbad700023dda44a977ed0722efa5880284
    HEAD_REF master
    PATCHES
        fix-install-path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUNIVERSAL_ENABLE_TESTS=OFF
        -DUNIVERSAL_VERBOSE_BUILD=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH CMake)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/include/universal/internal/variablecascade"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
