vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libffi/libffi/releases/download/v${VERSION}/libffi-${VERSION}.tar.gz"
    FILENAME "libffi-${VERSION}.tar.gz"
    SHA512 033d2600e879b83c6bce0eb80f69c5f32aa775bf2e962c9d39fbd21226fa19d1e79173d8eaa0d0157014d54509ea73315ad86842356fc3a303c0831c94c6ab39
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
if(VCPKG_DETECTED_CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    set(ccas "${SOURCE_PATH}/msvcc.sh")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        string(APPEND ccas_options " -m32")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        string(APPEND ccas_options " -m64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        string(APPEND ccas_options " -marm")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        string(APPEND ccas_options " -marm64")
    endif()
else()
    set(ccas "${VCPKG_DETECTED_CMAKE_C_COMPILER}")
endif()
cmake_path(GET ccas PARENT_PATH ccas_dir)
vcpkg_add_to_path("${ccas_dir}")
cmake_path(GET ccas FILENAME ccas_command)
vcpkg_list(APPEND options "CCAS=${ccas_command}${ccas_options}")

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
