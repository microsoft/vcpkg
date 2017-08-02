include(vcpkg_common_functions)

set(GM_VERSION 1.3.26)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/graphicsmagick-${GM_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/1.3.25/GraphicsMagick-${GM_VERSION}.tar.bz2"
    FILENAME "GraphicsMagick-${GM_VERSION}.tar.bz2"
    SHA512 c8791ec0e42527e90c602713c52826d1b8e8bbce7861f8cb48083d0f32465399c4f9a86f44342c5670f2fe54e6c5da878241ddf314c67d7fa98542b912ff61ba
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

# GM always requires a dynamic BZIP2. This patch makes this dependent if _DLL is defined
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/dynamic_bzip2.patch)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

# copy license
file(COPY ${SOURCE_PATH}/Copyright.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/graphicsmagick)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/graphicsmagick/Copyright.txt ${CURRENT_PACKAGES_DIR}/share/graphicsmagick/copyright)

# copy config
file(COPY ${SOURCE_PATH}/config/colors.mgk DESTINATION ${CURRENT_PACKAGES_DIR}/share/graphicsmagick/config)
file(COPY ${SOURCE_PATH}/config/log.mgk DESTINATION ${CURRENT_PACKAGES_DIR}/share/graphicsmagick/config)
file(COPY ${SOURCE_PATH}/config/modules.mgk DESTINATION ${CURRENT_PACKAGES_DIR}/share/graphicsmagick/config)

file(READ ${SOURCE_PATH}/config/type-windows.mgk.in TYPE_MGK)
string(REPLACE "@windows_font_dir@" "$ENV{SYSTEMROOT}/Fonts/" TYPE_MGK "${TYPE_MGK}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/graphicsmagick/config/type.mgk "${TYPE_MGK}")

vcpkg_copy_pdbs()
