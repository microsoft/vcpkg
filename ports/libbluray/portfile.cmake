vcpkg_from_gitlab(
    GITLAB_URL https://code.videolan.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO videolan/libbluray
    REF "${VERSION}"
    SHA512 8ee2014bfa0d44d046500818ad6f3795e01b77e4cc59d1b61ee56bfa4bfcb80e9e89ea4f452767eda3f14e6d9b5d305f0e7ed01ce00c570415958cae8ab692a4
)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    list(APPEND options -Dfontconfig=enabled)
else()
    list(APPEND options -Dfontconfig=disabled)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Denable_tools=false
        -Dbdj_jar=disabled
        -Dfreetype=enabled
        -Dlibxml2=enabled
        ${options}
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
