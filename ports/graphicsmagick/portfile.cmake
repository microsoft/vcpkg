include(vcpkg_common_functions)

set(GM_VERSION 1.3.25)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/graphicsmagick-${GM_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/1.3.25/GraphicsMagick-${GM_VERSION}.tar.bz2"
    FILENAME "GraphicsMagick-${GM_VERSION}.tar.bz2"
    SHA512 718802f675988ae36122e8a5f88c74754fa610ec2b4d4630772db7d8898c2e48117ea85fd6741c0b6f256f6f4d68abb642cdeddfb3d330ae1ab2951920cdc1a3
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
