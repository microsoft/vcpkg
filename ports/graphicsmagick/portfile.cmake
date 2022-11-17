set(GM_VERSION 1.3.37)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO graphicsmagick/graphicsmagick
    REF ${GM_VERSION}
    FILENAME "GraphicsMagick-${GM_VERSION}-windows.7z"
    SHA512 2e465a290946d730c0da1b45602ebdebc256d9a0705d6d79784efcefb0760a923dd78c73f7a563ce6ec41e4199da66d3b31cc8c6b8f821ff993092d348aeaa2f
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

configure_file(${SOURCE_PATH}/config/delegates.mgk.in ${CURRENT_PACKAGES_DIR}/share/${PORT}/config/delegates.mgk @ONLY)
vcpkg_copy_pdbs()
