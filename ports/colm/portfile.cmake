vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO adrian-thurston/colm
    REF "${VERSION}"
    SHA512 9328689be147ec5310a45e5a1adf8e420c01cc5c1a10def22229721698fabb320d99f4ecd3a599b1d92abc75e579d46a73a6a1fc16f9c6c46f1f5da9c39cbdf4
    HEAD_REF master
    PATCHES
        fixup-build.patch
)

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    COPY_SOURCE
    OPTIONS
        --disable-manual
        --disable-debug
)

vcpkg_make_install()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/colm-wrap" "COLM=${CURRENT_INSTALLED_DIR}/bin/\$CMD" "echo unable to find colm\n\t\t\texit 1")
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/colm-wrap" "COLM=${CURRENT_INSTALLED_DIR}/debug/bin/\$CMD" "echo unable to find colm\n\t\t\texit 1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
