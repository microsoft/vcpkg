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
        0006-typedef-off_t.diff
)

file(COPY
        "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
        "${CMAKE_CURRENT_LIST_DIR}/librtmp.def"
    DESTINATION "${SOURCE_PATH}/librtmp"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        crypto LIBRTMP_CRYPTO
)
if(LIBRTMP_CRYPTO)
    list(APPEND FEATURE_OPTIONS "-DLIBRTMP_SSL=OPENSSL")
endif()

include(CMakePrintHelpers)
cmake_print_variables(FEATURE_OPTIONS)
vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}/librtmp"
    OPTIONS
        -DVERSION=2.3
        -DLIBRTMP_SO_VERSION=1
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME "unofficial-librtmp")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/librtmp/COPYING")
