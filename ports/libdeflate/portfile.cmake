vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ebiggers/libdeflate
    REF "v${VERSION}"
    SHA512 4e2c0f78e55befc8cbc390722ee5e9e7662315eaafe1979e300972990acf4afffc32a1220cca7a6e944d551a430dd13d36b40066dfe8141789de1a5418ac620f
    HEAD_REF master
    PATCHES
        remove_wrong_c_flags_modification.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        compression   LIBDEFLATE_COMPRESSION_SUPPORT
        decompression LIBDEFLATE_DECOMPRESSION_SUPPORT
        gzip          LIBDEFLATE_ZLIB_SUPPORT
        zlib          LIBDEFLATE_GZIP_SUPPORT
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LIBDEFLATE_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBDEFLATE_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBDEFLATE_BUILD_SHARED_LIB=${LIBDEFLATE_BUILD_SHARED}
        -DLIBDEFLATE_BUILD_STATIC_LIB=${LIBDEFLATE_BUILD_STATIC}
        -DLIBDEFLATE_BUILD_GZIP=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/libdeflate")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
