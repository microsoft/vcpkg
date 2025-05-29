vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libffi/libffi/releases/download/v${VERSION}/libffi-${VERSION}.tar.gz"
    FILENAME "libffi-${VERSION}.tar.gz"
    SHA512 05344c6c1a1a5b44704f6cf99277098d1ea3ac1dc11c2a691c501786a214f76184ec0637135588630db609ce79e49df3dbd00282dd61e7f21137afba70e24ffe
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

##### For vcpkg-make.
##### TODO: Make vcpkg-cmake-get-vars robust and open for options.
list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS
    "-DVCPKG_DEFAULT_VARS_TO_CHECK=CMAKE_LIBRARY_PATH_FLAG"
    "-DVCPKG_LANGUAGES=C\\;CXX\\;ASM"
)
#####
#####

set(languages C CXX ASM)
vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")
if(VCPKG_DETECTED_CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    list(REMOVE_ITEM languages ASM) # using the following flags instead.
    vcpkg_add_to_path("${SOURCE_PATH}")
    vcpkg_list(APPEND options "CCAS=msvcc.sh")
    set(ccas_options "")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        string(APPEND ccas_options " -m32")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        string(APPEND ccas_options " -m64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        string(APPEND ccas_options " -marm")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        string(APPEND ccas_options " -marm64")
    endif()
    if(ccas_options)
        vcpkg_list(APPEND options "CCASFLAGS=\${CCASFLAGS}${ccas_options}")
    endif()
endif()

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    LANGUAGES ${languages}
    OPTIONS
        --enable-portable-binary
        --disable-docs
        --disable-multi-os-directory
        ${options}
)

vcpkg_make_install()
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
