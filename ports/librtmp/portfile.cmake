vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL git://git.ffmpeg.org/rtmpdump.git
    REF 6f6bb1353fc84f4cc37138baa99f586750028a01
    PATCHES
        fix_strncasecmp.patch
        hide_netstackdump.patch
        fix_version.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/librtmp.def" DESTINATION "${SOURCE_PATH}/librtmp")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# License and man
file(INSTALL "${SOURCE_PATH}/librtmp/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/librtmp/librtmp.3.html" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_copy_pdbs()
