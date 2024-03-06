vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/glog
    REF "v${VERSION}"
    SHA512 7222bb432c2b645238018233b2d18f254156617ef2921d18d17364866a7a3a05533fff1d63fd5033e1e5d3746a11806d007e7a36efaff667a0d3006dee45c278
    HEAD_REF master
    PATCHES
      fix_glog_CMAKE_MODULE_PATH.patch
      glog_disable_debug_postfix.patch
      fix_crosscompile_symbolize.patch
      fix_cplusplus_macro.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        unwind          WITH_UNWIND
        customprefix    WITH_CUSTOM_PREFIX
)
file(REMOVE "${SOURCE_PATH}/glog-modules.cmake.in")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/glog)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/${PORT}/export.h" "#ifdef GLOG_STATIC_DEFINE" "#if 1")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/${PORT}/export.h" "#ifdef GLOG_STATIC_DEFINE" "#if 0")
endif()
    
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
