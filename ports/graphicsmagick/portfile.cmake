set(GM_VERSION 1.3.41)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO graphicsmagick/graphicsmagick
    REF ${GM_VERSION}
    FILENAME "GraphicsMagick-${GM_VERSION}-windows.7z"
    SHA512 4790081136af67bf406b94e3de88feff295cc98fd3b125776e014436b12dbb31331af4ee4f8497ccc39d4afda08145b5e4bfeb45b3210a50e17b14e4dc2a220d
    PATCHES
        # GM always requires a dynamic BZIP2. This patch makes this dependent if _DLL is defined
        dynamic_bzip2.patch

        # Bake GM's own modules into the .dll itself.  This fixes a bug whereby
        # 'vcpkg install graphicsmagick' did not lead to a copy of GM that could
        # load either PNG or JPEG files (due to missing GM Modules, with names
        # matching "IM_*.DLL").
        disable_graphicsmagick_modules.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/magick_types.h" DESTINATION "${SOURCE_PATH}/magick")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-graphicsmagick)

# copy license
file(INSTALL "${SOURCE_PATH}/Copyright.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# copy config
file(COPY "${SOURCE_PATH}/config/colors.mgk" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/config")
file(COPY "${SOURCE_PATH}/config/log.mgk" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/config")
file(COPY "${SOURCE_PATH}/config/modules.mgk" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/config")

file(READ "${SOURCE_PATH}/config/type-windows.mgk.in" TYPE_MGK)
string(REPLACE "@windows_font_dir@" "$ENV{SYSTEMROOT}/Fonts/" TYPE_MGK "${TYPE_MGK}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/graphicsmagick/config/type.mgk" "${TYPE_MGK}")

configure_file("${SOURCE_PATH}/config/delegates.mgk.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/config/delegates.mgk" @ONLY)
vcpkg_copy_pdbs()
