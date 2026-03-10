vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO repology/libversion
    REF ${VERSION}
    SHA512 5be723103f33d764ad9c426fb915144d7ab0ca0de9c2650099060a543d01184c68d0849325d964b4815372ae9d71c9dbcb114049828ccd87d6dd6ad186d91fee
    HEAD_REF master
    PATCHES
        disable-test.patch
        separate-build-type.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libversion)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
