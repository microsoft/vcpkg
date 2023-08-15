vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libffi/libffi/releases/download/v${VERSION}/libffi-${VERSION}.tar.gz"
    FILENAME "libffi-${VERSION}.tar.gz"
    SHA512 88680aeb0fa0dc0319e5cd2ba45b4b5a340bc9b4bcf20b1e0613b39cd898f177a3863aa94034d8e23a7f6f44d858a53dcd36d1bb8dee13b751ef814224061889
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

set(extra_cflags "-DFFI_BUILDING")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    string(APPEND extra_cflags " -DFFI_BUILDING_DLL")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    DETERMINE_BUILD_TRIPLET
    USE_WRAPPERS
    OPTIONS
        --enable-portable-binary
        --disable-docs
        "CFLAGS=\${CFLAGS} ${extra_cflags}"
)

# WIP
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libtool" DESTINATION "${CURRENT_BUILDTREES_DIR}" RENAME "libtool-${TARGET_TRIPLET}-dbg.log")

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/ffi.h" "!defined FFI_BUILDING" "0")
endif()

# legacy vcpkg lock-in
configure_file("${CMAKE_CURRENT_LIST_DIR}/${PORT}Config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}Config.cmake" @ONLY)
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
