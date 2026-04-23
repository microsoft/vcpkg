#TODO: look for a way to use the --head version for port development
set(VCPKG_USE_HEAD_VERSION TRUE)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libvips/libvips
    REF v${VERSION}
    SHA512 f8acf184efe1855ad3e65d7393a57dff219b812cc5fb368e8020e8cf12f7a12dec7c7ce954669a3055ad7792eb8905ef2e9c72b8d6b8ff597720403073b65468
    HEAD_REF master
)

vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/glib/")

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(
    TOOL_NAMES
        vips
		vipsedit
		vipsheader
		vipsthumbnail
    AUTO_CLEAN
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
