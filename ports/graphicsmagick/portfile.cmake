string(REPLACE "." "_" graphicsmagick_version "GraphicsMagick-${VERSION}")

vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://foss.heptapod.net/
    REPO graphicsmagick/graphicsmagick
    REF ${graphicsmagick_version}
    SHA512 c6ee4ded9df4816c5f9522b825d51d23b8c3bef3218b630891f16950452a98633c6a9076b87c07b47493af44b6b4c4cfddfed456a715c885ac3d1d4c6252a6a7
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
