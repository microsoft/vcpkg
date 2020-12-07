set(RTMPDUMP_REVISION c5f04a58fc2aeea6296ca7c44ee4734c18401aa3)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://git.ffmpeg.org/rtmpdump
    REF ${RTMPDUMP_REVISION}
    SHA512 c21d8895407b087a59b264321d1605b51b09e4342bb46e772575b9ed429308373f1ac388eaacdcb3c2235c6c6243700392e217e91a0c342786a8c97313c217df
    PATCHES
        dh.patch                #Openssl 1.1.1 patch
        handshake.patch         #Openssl 1.1.1 patch
        hashswf.patch           #Openssl 1.1.1 patch
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
