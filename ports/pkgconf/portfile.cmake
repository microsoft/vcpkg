vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pkgconf/pkgconf
    REF cef30268e1a3f79efd607c26abcf556aa314c9c4 
    SHA512 ea03b81d01521201bdc471a39cdc8b13f9452f7cc78706d5c57056595f3e4e8a3562c022ebb72ce6444f2c7a8dfc778114814ef5064eaef770a70cc294c7f7ee
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    NO_PKG_CONFIG
    OPTIONS -Dtests=false
    )
vcpkg_install_meson()
vcpkg_fixup_pkgconfig(SKIP_CHECK)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/pkgconf/libpkgconf/libpkgconf-api.h" "#if defined(PKGCONFIG_IS_STATIC)" "#if 1")
endif()

vcpkg_copy_tools(TOOL_NAMES pkgconf AUTO_CLEAN)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
