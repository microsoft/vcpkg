if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JosephP91/curlcpp
    REF "${VERSION}"
    SHA512 9c84dff893ac4f7a02b6b360d72f9cf65a69ca33bed6c35ceef21cef2f20c1eb36664fdb3e2918a39a88f88bd4104d9d09f5d40168847a3be83135958bd41046
    HEAD_REF master
    PATCHES
        fix-cmake.patch
        obsolete-curlopt.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT} PACKAGE_NAME "curlcpp")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")