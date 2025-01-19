vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mirror/rtmpdump
    REF 6f6bb1353fc84f4cc37138baa99f586750028a01
    SHA512 e6c108576fdd3430d81e2f72b343864eee5d6be396c9378a2ae2bfc871e9464e20d7bd057a47ef2449a301d933b29265e7ffd3383631b24fc035f5483337bbce
    PATCHES
        fix_strncasecmp.patch
        hide_netstackdump.patch
        pkgconfig.patch
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
        -DVERSION=2.6
        -DLIBRTMP_SO_VERSION=1
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME "unofficial-librtmp")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/librtmp/COPYING")
