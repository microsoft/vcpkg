set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL "https://gitlab.freedesktop.org"
    REPO "xdg/shared-mime-info"
    REF "${VERSION}"
    SHA512 203fe6625d3e6b5236a86788bddcf11147815b483c713b1b3efeea15d5d55a77ddb88074e46377c6dd1e7bb2d5c0c0f9b34adf6f057398ef872bad0d421360c2
)

set(VCPKG_BUILD_TYPE release)  # only data

vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/libxml2")

# msgfmt can't deal with drive letters on Windows, so we need to use a relative data dir
file(RELATIVE_PATH GETTEXTDATADIRREL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}" "${SOURCE_PATH}/data")
set(ENV{GETTEXTDATADIR} "${GETTEXTDATADIRREL}")

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dupdate-mimedb=false
        -Dbuild-spec=false
        -Dbuild-tools=false
        -Dbuild-translations=false
        -Dbuild-tests=false
)

vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

