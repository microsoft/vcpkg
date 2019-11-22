set(RTMPDUMP_REVISION c5f04a58fc2aeea6296ca7c44ee4734c18401aa3)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://git.ffmpeg.org/rtmpdump
    REF ${RTMPDUMP_REVISION}
    PATCHES
        fix_strncasecmp.patch
        hide_netstackdump.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/librtmp.def DESTINATION ${SOURCE_PATH}/librtmp)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# License and man
file(INSTALL ${SOURCE_PATH}/librtmp/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/librtmp RENAME copyright)
file(INSTALL ${SOURCE_PATH}/librtmp/librtmp.3.html DESTINATION ${CURRENT_PACKAGES_DIR}/share/librtmp)

vcpkg_copy_pdbs()
