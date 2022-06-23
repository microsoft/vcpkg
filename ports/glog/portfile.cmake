vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/glog
    REF v0.6.0
    SHA512 fd2c42583d0dd72c790a8cf888f328a64447c5fb9d99b2e2a3833d70c102cb0eb9ae874632c2732424cc86216c8a076a3e24b23a793eaddb5da8a1dc52ba9226
    HEAD_REF master
    PATCHES
      fix_glog_CMAKE_MODULE_PATH.patch
      glog_disable_debug_postfix.patch
      fix_crosscompile_symbolize.patch
      fix_cplusplus_macro.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    unwind     WITH_UNWIND
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

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
