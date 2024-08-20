vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mirror/rtmpdump
    REF c5f04a58fc2aeea6296ca7c44ee4734c18401aa3
    SHA512 d97ac38672898a96412baa5f03d1e64d512ccefe15ead0a055ca039dc6057e2e620e046c28f4d7468e132b0b5a9eb9bd171250c1afa14da53760a0d7aae3c9e9
    PATCHES
        dh.patch                #Openssl 1.1.1 patch
        handshake.patch         #Openssl 1.1.1 patch
        hashswf.patch           #Openssl 1.1.1 patch
        fix_strncasecmp.patch
        hide_netstackdump.patch
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
