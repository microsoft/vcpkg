vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kio
    REF "v${VERSION}"
    SHA512 085eaf467cb70630b1a2fe5024bd45aebe47f15c397388ebd562d0c0fbfd6700c8cc50d2ec136988d9575173aa01a5a73a1550c1b7cbb93d6909941909a31db7
    HEAD_REF master
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
        -DCMAKE_DISABLE_FIND_PACKAGE_GSSAPI=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_KF5DocTools=ON
        -DCMAKE_VERBOSE_MAKEFILE=ON
        -DKDE_INSTALL_QTPLUGINDIR=plugins
        -DKDE_INSTALL_PLUGINDIR=plugins
        -DKDE_INSTALL_LIBEXECDIR=bin
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_KF5Notifications
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5KIO)
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
