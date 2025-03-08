vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libffi/libffi/releases/download/v${VERSION}/libffi-${VERSION}.tar.gz"
    FILENAME "libffi-${VERSION}.tar.gz"
    SHA512 d19f59a5b5d61bd7d9e8a7a74b8bf2e697201a19c247c410c789e93ca8678a4eb9f13c9bee19f129be80ade8514f6b1acb38d66f44d86edd32644ed7bbe31dd6
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        dll-bindir.diff
)

vcpkg_list(SET options)
if(VCPKG_TARGET_IS_WINDOWS)
    set(linkage_flag "-DFFI_STATIC_BUILD")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(linkage_flag "-DFFI_BUILDING_DLL")
    endif()
    vcpkg_list(APPEND options "CFLAGS=\${CFLAGS} ${linkage_flag}")
endif()

set(ccas_options "")
vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")
set(ccas "${VCPKG_DETECTED_CMAKE_C_COMPILER}")
if(VCPKG_DETECTED_CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    vcpkg_add_to_path("${SOURCE_PATH}")
    set(ccas "msvcc.sh")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        string(APPEND ccas_options " -m32")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        string(APPEND ccas_options " -m64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        string(APPEND ccas_options " -marm")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        string(APPEND ccas_options " -marm64")
    endif()
endif()
vcpkg_list(APPEND options "CCAS=${ccas}")
if(ccas_options)
    vcpkg_list(APPEND options "CCASFLAGS=\${CCASFLAGS}${ccas_options}")
endif()

set(configure_triplets DETERMINE_BUILD_TRIPLET)
if(VCPKG_TARGET_IS_EMSCRIPTEN)
    set(configure_triplets BUILD_TRIPLET "--host=wasm32-unknown-emscripten --build=\$(\$SHELL \"${SOURCE_PATH}/config.guess\")")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    ${configure_triplets}
    USE_WRAPPERS
    OPTIONS
        --enable-portable-binary
        --disable-docs
        --disable-multi-os-directory
        ${options}
)

vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/ffi.h" "defined(FFI_STATIC_BUILD)" "1")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-libffi-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-libffi")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/libffiConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/man3"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
