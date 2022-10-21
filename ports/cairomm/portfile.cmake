set(CAIROMM_VERSION 1.16.2)
set(CAIROMM_HASH 61dc639eabe8502e1262c53c92fe57c5647e5ab9931f86ed51e657df1b7d0e3e58c2571910a05236cc0dca8d52f1f693aed99a553430f14d0fb87be1832a6b62)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.cairographics.org/releases/cairomm-${CAIROMM_VERSION}.tar.xz"
    FILENAME "cairomm-${CAIROMM_VERSION}.tar.xz"
    SHA512 ${CAIROMM_HASH}
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
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
