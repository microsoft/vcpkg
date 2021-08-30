vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kio
    REF v5.84.0
    SHA512 6c2d57a31e64ff1475b21d7fb2556d37b061dae319ddfe57a36f0bfc9627db624b1ac8fa4b2851681cb90d218255d0444c1403329d88f34a23e8ddffe99ca5b4
    HEAD_REF master
    PATCHES
        fix_dbusmetatypes.patch
        fix_libiconv.patch
)

vcpkg_cmake_configure(
    DISABLE_PARALLEL_CONFIGURE
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_VERBOSE_MAKEFILE=ON
        -DKDE_INSTALL_QTPLUGINDIR=plugins
        -DKDE_INSTALL_PLUGINDIR=plugins
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5KIO)
vcpkg_copy_pdbs()

vcpkg_copy_tools(
    TOOL_NAMES kcookiejar5 ktelnetservice5 ktrash5 protocoltojson
    AUTO_CLEAN
)

vcpkg_copy_tools(
    TOOL_NAMES kio_http_cache_cleaner kiod5 kioexec kioslave5 kpac_dhcp_helper
    SEARCH_DIR "${CURRENT_PACKAGES_DIR}/lib/libexec/kf5/"
    AUTO_CLEAN
)

file(APPEND "${CURRENT_PACKAGES_DIR}/tools/${PORT}/qt.conf" "Data = ../../share")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")