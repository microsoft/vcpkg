include(vcpkg_common_functions)

set(GM_VERSION 1.3.26)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/graphicsmagick-${GM_VERSION}-windows-source)

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/${GM_VERSION}/GraphicsMagick-${GM_VERSION}-windows-source.7z"
    FILENAME "GraphicsMagick-${GM_VERSION}-windows-source.7z"
    SHA512 c45a054d082d9a7a2889a2235dd5b96bd564acf55bd581426ecd32c426f9797d7d56d6e5f25a5a7da8ebd26bf0d962372b5d48d86532dc6c57522d27c0d18ec8
    )
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/magick_types.h DESTINATION ${SOURCE_PATH}/magick)

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
