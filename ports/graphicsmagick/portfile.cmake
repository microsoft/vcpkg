include(vcpkg_common_functions)

set(GM_VERSION 1.3.33)

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/${GM_VERSION}/GraphicsMagick-${GM_VERSION}-windows-source.7z"
    FILENAME "GraphicsMagick-${GM_VERSION}-windows-source.7z"
	SHA512 856fafe36693a7963f5944f489f4b7a0d15d9dcc575f96d31486e3abd886f681854cbb2271feb4b4cb19668480904d473138a2d9c2ec95539de705d75e2f49c9
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF "${GM_VERSION}"
    PATCHES
        # GM always requires a dynamic BZIP2. This patch makes this dependent if _DLL is defined
        dynamic_bzip2.patch

        # Bake GM's own modules into the .dll itself.  This fixes a bug whereby
        # 'vcpkg install graphicsmagick' did not lead to a copy of GM that could
        # load either PNG or JPEG files (due to missing GM Modules, with names
        # matching "IM_*.DLL").
        disable_graphicsmagick_modules.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/magick_types.h DESTINATION ${SOURCE_PATH}/magick)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-graphicsmagick TARGET_PATH share/unofficial-graphicsmagick)

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

vcpkg_test_cmake(PACKAGE_NAME unofficial-graphicsmagick)
