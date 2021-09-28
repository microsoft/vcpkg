set(PATCHES
    fix_dbusmetatypes.patch # https://invent.kde.org/frameworks/kio/-/merge_requests/563
    fix_config_cmake.patch # https://invent.kde.org/frameworks/kio/-/merge_requests/565
)

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL static)
    list(APPEND PATCHES fix_libiconv.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kio
    REF v5.84.0
    SHA512 6c2d57a31e64ff1475b21d7fb2556d37b061dae319ddfe57a36f0bfc9627db624b1ac8fa4b2851681cb90d218255d0444c1403329d88f34a23e8ddffe99ca5b4
    HEAD_REF master
    PATCHES ${PATCHES}
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  INVERTED_FEATURES
    "kf5notifications"  CMAKE_DISABLE_FIND_PACKAGE_KF5Notifications
    "kf5wallet"         CMAKE_DISABLE_FIND_PACKAGE_KF5Wallet
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE ${SOURCE_PATH}/.clang-format "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_VERBOSE_MAKEFILE=ON
        -DKDE_INSTALL_QTPLUGINDIR=plugins
        -DKDE_INSTALL_PLUGINDIR=plugins
        -DKDE_INSTALL_LIBEXECDIR=bin
        ${FEATURE_OPTIONS}
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

file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")