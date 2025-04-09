if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gflags/gflags
    REF v2.2.2
    SHA512 98c4703aab24e81fe551f7831ab797fb73d0f7dfc516addb34b9ff6d0914e5fd398207889b1ae555bac039537b1d4677067dae403b64903577078d99c1bdb447
    HEAD_REF master
    PATCHES
        0001-patch-dir.patch # gflags was estimating a wrong relative path between the gflags-config.cmake file and the include path; "../.." goes from share/gflags/ to the triplet root
        fix_cmake_config.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGFLAGS_REGISTER_BUILD_DIR:BOOL=OFF
        -DGFLAGS_REGISTER_INSTALL_PREFIX:BOOL=OFF
        -DBUILD_gflags_nothreads_LIB:BOOL=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/gflags)
if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_pkgconfig()
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gflags.pc" "-lgflags" "-lgflags_debug")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.txt")


