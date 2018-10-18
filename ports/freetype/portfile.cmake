include(vcpkg_common_functions)
set(FT_VERSION 2.8.1)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/freetype-${FT_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://download-mirror.savannah.gnu.org/releases/freetype/freetype-${FT_VERSION}.tar.bz2"
    FILENAME "freetype-${FT_VERSION}.tar.bz2"
    SHA512 ca59e47f0fceeeb9b8032be2671072604d0c79094675df24187829c05e99757d0a48a0f8062d4d688e056f783aa8f6090d732ad116562e94784fccf1339eb823
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/0001-Support-Windows-DLLs-via-CMAKE_WINDOWS_EXPORT_ALL_SY.patch
            ${CMAKE_CURRENT_LIST_DIR}/0002-Add-CONFIG_INSTALL_PATH-option.patch
            ${CMAKE_CURRENT_LIST_DIR}/0003-Fix-UWP.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCONFIG_INSTALL_PATH=share/freetype
        -DWITH_ZLIB=ON
        -DWITH_BZip2=ON
        -DWITH_PNG=ON
        -DWITH_HarfBuzz=OFF
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
string(REPLACE "\${_IMPORT_PREFIX}/include/freetype2" "\${_IMPORT_PREFIX}/include/freetype" CONFIG_MODULE "${CONFIG_MODULE}")
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
