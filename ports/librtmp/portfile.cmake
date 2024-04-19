vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://git.ffmpeg.org/rtmpdump.git
    REF 6f6bb1353fc84f4cc37138baa99f586750028a01
    PATCHES
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
        -DVERSION=${VERSION}
        -DLIBRTMP_SO_VERSION=1
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME "unofficial-librtmp")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/librtmp/COPYING")
