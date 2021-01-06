vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

set(ATK_VERSION 2.24.0)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/atk/2.24/atk-${ATK_VERSION}.tar.xz"
    FILENAME "atk-${ATK_VERSION}.tar.xz"
    SHA512 3ae0a4d5f28d5619d465135c685161f690732053bcb70a47669c951fbf389b5d2ccc5c7c73d4ee8c5a3b2df14e2f5b082e812a215f10a79b27b412d077f5e962
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        fix-linux-config.patch
)

# Here are used API version of library, not the version of library itself
set(ATK_LIB_SUFFIX 1.0)
set(ATK_DLL_SUFFIX 1)

set(GLIB_LIB_VERSION 2.0)
if (WIN32)
    set(ATK_API_VERSION ${ATK_LIB_SUFFIX})
else()
    set(ATK_API_VERSION ${ATK_DLL_SUFFIX})
endif()
configure_file("${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt.in" "${SOURCE_PATH}/CMakeLists.txt" @ONLY)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_PROGRAM_PATH=${CURRENT_INSTALLED_DIR}/tools/glib
        -DGETTEXT_PACKAGE=atk10
        -DVERSION=10
    OPTIONS_DEBUG
        -DATK_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
