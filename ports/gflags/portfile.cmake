if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gflags/gflags
    REF v${VERSION}
    SHA512 d1e3971c2db6e0cba16fc6438213866c3e031bed73b3332ae3ca3a6e6f14fd17c8881ad8fa9716a4c468171c8d7cbd26d4049fc4af8ed4888c3a0ad913ea24da
    HEAD_REF master
    PATCHES
        0001-patch-dir.patch # gflags was estimating a wrong relative path between the gflags-config.cmake file and the include path; "../.." goes from share/gflags/ to the triplet root
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


