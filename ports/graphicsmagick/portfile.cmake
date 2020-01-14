set(GM_VERSION 1.3.34)

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/${GM_VERSION}/GraphicsMagick-${GM_VERSION}-windows-source.7z"
    FILENAME "GraphicsMagick-${GM_VERSION}-windows-source.7z"
	SHA512 bc770070d3e6b58ded1932050c1aa9f31edd89ac68e12055d7bb481ba9aa8e7509e69ad676a1624c262f9b55c0ceeea738b807005946ddd97b88d49b39b8a073
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
file(INSTALL ${SOURCE_PATH}/Copyright.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# copy config
file(COPY ${SOURCE_PATH}/config/colors.mgk DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/config)
file(COPY ${SOURCE_PATH}/config/log.mgk DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/config)
file(COPY ${SOURCE_PATH}/config/modules.mgk DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/config)

file(READ ${SOURCE_PATH}/config/type-windows.mgk.in TYPE_MGK)
string(REPLACE "@windows_font_dir@" "$ENV{SYSTEMROOT}/Fonts/" TYPE_MGK "${TYPE_MGK}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/graphicsmagick/config/type.mgk "${TYPE_MGK}")

vcpkg_copy_pdbs()
