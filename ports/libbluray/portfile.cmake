vcpkg_from_gitlab(
    GITLAB_URL https://code.videolan.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO videolan/libbluray
    REF "${VERSION}"
    SHA512 d643db1e9fdc5f3b31ea44b7fc5725dbb2824d2bd8e1ef516ead76a42e92192cb7c332340c43de628158b867835259ad27f07fd7da8a3b0992608177908a0530
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
