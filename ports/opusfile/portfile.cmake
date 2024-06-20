vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/opusfile
    REF "9d718345ce03b2fad5d7d28e0bcd1cc69ab2b166" # https://github.com/xiph/opusfile/compare/v0.12...9d71834
    SHA512 17e323d6c031330f10b045a1438cd7ba44e2ac313ec7b3d69a8041dfa927c3f501d04246d974109fbd68dfa1a8d7b63584d96caed69ad5e38b68358aa35af65a
    HEAD_REF master)

file(WRITE "${SOURCE_PATH}/package_version" "PACKAGE_VERSION=${VERSION}")

vcpkg_replace_string("${SOURCE_PATH}/cmake/OpusFileConfig.cmake.in" "opusfileTargets.cmake" "OpusFileTargets.cmake")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        opusurl OP_DISABLE_HTTP
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DOP_DISABLE_DOCS=ON
        -DOP_DISABLE_EXAMPLES=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/opusfile")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Create the pkg-config files
set(prefix "")
set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/include")
set(PACKAGE_VERSION "${VERSION}")
set(lrintf_lib "")
configure_file("${SOURCE_PATH}/opusfile.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/opusfile.pc" @ONLY)
if(NOT VCPKG_BUILD_TYPE)
    configure_file("${SOURCE_PATH}/opusfile.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/opusfile.pc" @ONLY)
endif()

if(opusurl IN_LIST FEATURES)
    set(openssl "openssl")
    configure_file("${SOURCE_PATH}/opusurl.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/opusurl.pc" @ONLY)
    if(NOT VCPKG_BUILD_TYPE)
        configure_file("${SOURCE_PATH}/opusurl.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/opusurl.pc" @ONLY)
    endif()
endif()

vcpkg_fixup_pkgconfig()

# make includes work with MSBuild integration
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/opus/opusfile.h" "# include <opus_multistream.h>" "# include \"opus_multistream.h\"")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
