include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

set(GDL_VERSION 3.28.0)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/gdl-${GDL_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnome.org/pub/GNOME/sources/gdl/3.28/gdl-${GDL_VERSION}.tar.xz"
    FILENAME "gdl-${GDL_VERSION}.tar.xz"
    SHA512 d6a697b8cd098abfcb560d8b6c8a326b05f6f22211a3bc92ea458d643170abc514acd4105e372fb61777d2a5dd09709d7e3d6d3ad75215fffdf2809b3df3c471)

# note: can't use vcpkg_from_gitlab because some generated files from .tar are needed

vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/msvc-compiler-fixes.patch
        ${CMAKE_CURRENT_LIST_DIR}/add-declspec-dllexport.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

set(GETTEXT_PACKAGE gdl-3)
configure_file(${CMAKE_CURRENT_LIST_DIR}/config.h.vcpkg.in ${SOURCE_PATH}/config.h @ONLY)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DGDL_SKIP_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/gdl)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gdl/COPYING ${CURRENT_PACKAGES_DIR}/share/gdl/copyright)
