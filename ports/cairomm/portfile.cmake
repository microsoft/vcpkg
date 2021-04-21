set(CAIROMM_VERSION 1.16.0)
set(CAIROMM_HASH 51929620feeac45377da5d486ea7a091bbd10ad8376fb16525328947b9e6ee740cdc8e8bd190a247b457cc9fec685a829c81de29b26cabaf95383ef04cce80d3)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.cairographics.org/releases/cairomm-${CAIROMM_VERSION}.tar.xz"
    FILENAME "cairomm-${CAIROMM_VERSION}.tar.xz"
    SHA512 ${CAIROMM_HASH}
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        undef.win32.patch # because WIN32 is used as an ENUM identifier. 
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Dbuild-examples=false
        -Dmsvc14x-parallel-installable=false    # Use separate DLL and LIB filenames for Visual Studio 2017 and 2019
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

if(VCPKG_LIBRARY_LINAKGE STREQUAL "static")
    set(_file "${CURRENT_PACKAGES_DIR}/lib/cairomm-1.16/include/cairommconfig.h")
    if(EXISTS "${_file}")
        vcpkg_replace_string("${_file}" "# define CAIROMM_DLL 1" "# undef CAIROMM_DLL\n# define CAIROMM_STATIC_LIB 1")
    endif()
    set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/cairomm-1.16/include/cairommconfig.h")
    if(EXISTS "${_file}")
        vcpkg_replace_string("${_file}" "# define CAIROMM_DLL 1" "# undef CAIROMM_DLL\n# define CAIROMM_STATIC_LIB 1")
    endif()
endif()
