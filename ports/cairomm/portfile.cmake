set(CAIROMM_VERSION 1.16.1)
set(CAIROMM_HASH 2dbdd41f712d43573ad3118f37d443d2b9ae98737c240d5db8d830ef38f2b4a95182b2fc857577c7564eb94649e629f70380f16ee84f4978759f40e19d802757)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.cairographics.org/releases/cairomm-${CAIROMM_VERSION}.tar.xz"
    FILENAME "cairomm-${CAIROMM_VERSION}.tar.xz"
    SHA512 ${CAIROMM_HASH}
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        build-support-msvc2022.diff
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
