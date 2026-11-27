vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://code.videolan.org/
    REPO videolan/libdvdnav
    REF "${VERSION}"
    SHA512 fc417e5481b9d1e770815baba067115c8f0c0ff682f326488ef9d5f6095e9431dd9546ec3666e39cba2540f1cf6d30866d45e59697adafdd62f09665dcca4827
    HEAD_REF master
    PATCHES
        msvc.diff
)
# The bundled header hides the system inttypes.h
file(REMOVE "${SOURCE_PATH}/msvc/include/inttypes.h")

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Denable_docs=false
        -Denable_examples=false
)

vcpkg_install_meson()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
