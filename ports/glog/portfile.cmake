vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/glog
    REF "v${VERSION}"
    SHA512 2dabac87d44e4fe58beceb31b22be732b47df84c22f1af8c0e7d0f262de939889de1f16025c1256539f2833ef3393bc92034e983aa2886752bb8705801a68630
    HEAD_REF master
    PATCHES
      fix_glog_CMAKE_MODULE_PATH.patch
      glog_disable_debug_postfix.patch
      fix_crosscompile_symbolize.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        unwind          WITH_UNWIND
        unwind          VCPKG_LOCK_FIND_PACKAGE_Unwind
)
file(REMOVE "${SOURCE_PATH}/glog-modules.cmake.in")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DWITH_PKGCONFIG=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/glog)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()

# Upstream hard-codes '-lgflags' and '-lunwind' in Libs.private.
if(VCPKG_TARGET_IS_WINDOWS)
    # gflags does not install a .pc file on Windows.
    set(gflags_release "-lgflags")
    set(gflags_debug "-lgflags_debug")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(gflags_release "-lgflags_static -lshlwapi")
        set(gflags_debug "-lgflags_static_debug -lshlwapi")
    endif()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libglog.pc" "-lgflags" "${gflags_release}")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libglog.pc" "-lgflags" "${gflags_debug}")
    endif()
else()
    set(glog_requires "gflags")
    if("unwind" IN_LIST FEATURES)
        string(APPEND glog_requires " libunwind")
    endif()
    set(glog_pc_files "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libglog.pc")
    if(NOT VCPKG_BUILD_TYPE)
        list(APPEND glog_pc_files "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libglog.pc")
    endif()
    foreach(glog_pc IN LISTS glog_pc_files)
        vcpkg_replace_string("${glog_pc}" "(Libs.private:[^\n]*) ?-lgflags" "\\1" REGEX)
        vcpkg_replace_string("${glog_pc}" "(Libs.private:[^\n]*) ?-lunwind" "\\1" REGEX IGNORE_UNCHANGED)
        file(APPEND "${glog_pc}" "Requires.private: ${glog_requires}\n")
    endforeach()
endif()
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/${PORT}/export.h" "#ifdef GLOG_STATIC_DEFINE" "#if 1")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/${PORT}/export.h" "#ifdef GLOG_STATIC_DEFINE" "#if 0")
endif()

if("unwind" IN_LIST FEATURES)
    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
