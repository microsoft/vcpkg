include(vcpkg_common_functions)

set(FT_VERSION 2.9.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://download-mirror.savannah.gnu.org/releases/freetype/freetype-${FT_VERSION}.tar.bz2" "https://downloads.sourceforge.net/project/freetype/freetype2/${FT_VERSION}/freetype-${FT_VERSION}.tar.bz2"
    FILENAME "freetype-${FT_VERSION}.tar.bz2"
    SHA512 856766e1f3f4c7dc8afb2b5ee991138c8b642c6a6e5e007cd2bc04ae58bde827f082557cf41bf541d97e8485f7fd064d10390d1ee597f19d1daed6c152e27708
)

if(NOT ${VCPKG_LIBRARY_LINKAGE} STREQUAL "dynamic")
    vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${FT_VERSION}
    PATCHES
        0001-Fix-install-command.patch
        0002-Add-CONFIG_INSTALL_PATH-option.patch
        0003-Fix-UWP.patch
        0004-Fix-DLL-install.patch
    )
else()
    vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${FT_VERSION}
    PATCHES
        0001-Fix-install-command.patch
        0002-Add-CONFIG_INSTALL_PATH-option.patch
        0003-Fix-UWP.patch
        0004-Fix-DLL-install.patch
        0005-Fix-DLL-EXPORTS.patch
    )
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
)

vcpkg_install_cmake()

file(RENAME ${CURRENT_PACKAGES_DIR}/include/freetype2/freetype ${CURRENT_PACKAGES_DIR}/include/freetype)
file(RENAME ${CURRENT_PACKAGES_DIR}/include/freetype2/ft2build.h ${CURRENT_PACKAGES_DIR}/include/ft2build.h)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/freetype2)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(READ ${CURRENT_PACKAGES_DIR}/debug/share/freetype/freetype-config-debug.cmake DEBUG_MODULE)
    string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" DEBUG_MODULE "${DEBUG_MODULE}")
    string(REPLACE "${CURRENT_INSTALLED_DIR}" "\${_IMPORT_PREFIX}" DEBUG_MODULE "${DEBUG_MODULE}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/freetype/freetype-config-debug.cmake "${DEBUG_MODULE}")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(READ ${CURRENT_PACKAGES_DIR}/share/freetype/freetype-config-release.cmake RELEASE_MODULE)
    string(REPLACE "${CURRENT_INSTALLED_DIR}" "\${_IMPORT_PREFIX}" RELEASE_MODULE "${RELEASE_MODULE}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/freetype/freetype-config-release.cmake "${RELEASE_MODULE}")
endif()

# Fix the include dir [freetype2 -> freetype]
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(READ ${CURRENT_PACKAGES_DIR}/debug/share/freetype/freetype-config.cmake CONFIG_MODULE)
else() #if(VCPKG_BUILD_TYPE STREQUAL "release")
    file(READ ${CURRENT_PACKAGES_DIR}/share/freetype/freetype-config.cmake CONFIG_MODULE)
endif()
string(REPLACE "\${_IMPORT_PREFIX}/include/freetype2" "\${_IMPORT_PREFIX}/include;\${_IMPORT_PREFIX}/include/freetype" CONFIG_MODULE "${CONFIG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/freetype/freetype-config.cmake "${CONFIG_MODULE}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY
    ${SOURCE_PATH}/docs/LICENSE.TXT
    ${SOURCE_PATH}/docs/FTL.TXT
    ${SOURCE_PATH}/docs/GPLv2.TXT
    ${CMAKE_CURRENT_LIST_DIR}/usage
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/freetype
)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/freetype/LICENSE.TXT ${CURRENT_PACKAGES_DIR}/share/freetype/copyright)
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/freetype)
endif()
