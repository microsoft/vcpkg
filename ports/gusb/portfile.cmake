vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hughsie/libgusb
    REF 0.4.5
    SHA512 034399f85916f76efc8316d5ca1d101cc8acd22ab928add32df9037d94798eaba5b1d5852aa10a9e4ae80d073a0d7d00626ab293817e66091c850d6847a61319
    HEAD_REF main
    PATCHES
        fix-windows-build.patch
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Ddocs=false
        -Dtests=false
        -Dtools=false
        -Dvapi=false
        -Dintrospection=false
    OPTIONS_DEBUG
        -Dc_args="/std:c11"
        -Dc_args="-DGUSB_COMPILATION"
    OPTIONS_RELEASE
        -Dc_args="/std:c11"
        -Dc_args="-DGUSB_COMPILATION"
)

vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
