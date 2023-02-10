vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "UWP builds not supported")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/opusfile
    REF "v${VERSION}"
    SHA512 c134b86a444acc3383b785bf89d02734d955b0547fd2ae55afa821b347d6a312130922893f5a27f48e822a6fddc35301048079e365b64c62cd3c7cadb33233b5
    HEAD_REF master)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        opusurl BUILD_OPUSURL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DOPUSFILE_SKIP_HEADERS=ON)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

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
