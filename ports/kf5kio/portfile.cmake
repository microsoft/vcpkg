if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL static)
    list(APPEND PATCHES fix_libiconv.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kio
    REF v5.98.0
    SHA512 6ffb44963b266f806150bc3ff9a1c3cf13f2fe7b4bda57e27d9bd9b931bfd757d50ee29f4143f6d282a25f675c8024aff16dc2f91e00ec0c7663eb8effdfee30
    HEAD_REF master
    PATCHES
        ${PATCHES}
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        "kf5notifications"  CMAKE_DISABLE_FIND_PACKAGE_KF5Notifications
        "kf5wallet"         CMAKE_DISABLE_FIND_PACKAGE_KF5Wallet
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_FIND_PACKAGE_TARGETS_GLOBAL=ON
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_KF5DocTools=ON
        -DCMAKE_VERBOSE_MAKEFILE=ON
        -DKDE_INSTALL_QTPLUGINDIR=plugins
        -DKDE_INSTALL_PLUGINDIR=plugins
        -DKDE_INSTALL_LIBEXECDIR=bin
        ${FEATURE_OPTIONS}
        --trace-expand
    MAYBE_UNUSED_VARIABLES CMAKE_DISABLE_FIND_PACKAGE_KF5Notifications
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5KIO CONFIG_PATH lib/cmake/KF5KIO)
vcpkg_copy_pdbs()

set(LIBEXEC_TOOLS kio_http_cache_cleaner kiod5 kioexec kioslave5)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    if(NOT VCPKG_TARGET_IS_ANDROID)
        list(APPEND LIBEXEC_TOOLS kpac_dhcp_helper)
    endif()

    list(TRANSFORM LIBEXEC_TOOLS PREPEND "kf5/")
endif()

vcpkg_copy_tools(
    TOOL_NAMES kcookiejar5 ktelnetservice5 ktrash5 protocoltojson ${LIBEXEC_TOOLS}
    AUTO_CLEAN
)

file(APPEND "${CURRENT_PACKAGES_DIR}/tools/${PORT}/qt.conf" "Data = ../../share")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})


