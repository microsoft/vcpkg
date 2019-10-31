include(vcpkg_common_functions)

set(FT_VERSION 2.10.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://download-mirror.savannah.gnu.org/releases/freetype/freetype-${FT_VERSION}.tar.xz" "https://downloads.sourceforge.net/project/freetype/freetype2/${FT_VERSION}/freetype-${FT_VERSION}.tar.xz"
    FILENAME "freetype-${FT_VERSION}.tar.xz"
    SHA512 c7a565b0ab3dce81927008a6965d5c7540f0dc973fcefdc1677c2e65add8668b4701c2958d25593cb41f706f4488765365d40b93da71dbfa72907394f28b2650
)

vcpkg_extract_source_archive_ex(
OUT_SOURCE_PATH SOURCE_PATH
ARCHIVE ${ARCHIVE}
REF ${FT_VERSION}
PATCHES
    0001-Fix-install-command.patch
    0002-Add-CONFIG_INSTALL_PATH-option.patch
    0003-Fix-UWP.patch
    0004-use-proper-pkg-config-version.patch
    0005-Fix-DLL-EXPORTS.patch
)

if(NOT ${VCPKG_LIBRARY_LINKAGE} STREQUAL "dynamic")
  set(ENABLE_DLL_EXPORT OFF)
else()
  set(ENABLE_DLL_EXPORT ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCONFIG_INSTALL_PATH=share/freetype
        -DFT_WITH_ZLIB=ON
        -DFT_WITH_BZIP2=ON
        -DFT_WITH_PNG=ON
        -DFT_WITH_HARFBUZZ=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_HarfBuzz=TRUE
        -DENABLE_DLL_EXPORT=${ENABLE_DLL_EXPORT}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
vcpkg_fixup_pkgconfig_targets()

file(READ ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/freetype2.pc PKGCONFIG_MODULE)
string(REPLACE "-lfreetype" "-lfreetype -lbz2 -lpng16 -lz" PKGCONFIG_MODULE "${PKGCONFIG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/freetype2.pc "${PKGCONFIG_MODULE}")
file(READ ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/freetype2.pc PKGCONFIG_MODULE)
string(REPLACE "-lfreetyped" "-lfreetyped -lbz2d -lpng16d -lzd" PKGCONFIG_MODULE "${PKGCONFIG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/freetype2.pc "${PKGCONFIG_MODULE}")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/docs/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/freetype)
endif()
