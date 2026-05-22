# data-only port
set(VCPKG_BUILD_TYPE release)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_gitlab(
    GITLAB_URL https://salsa.debian.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO iso-codes-team/iso-codes
    REF "v${VERSION}"
    SHA512 2b5690b109da3d4f969c62f1a9653f6a12f6529794b97d0c834d708ff9a407bc0193047992b2acea7525f4638a68dbd9a6dceec8b0b0d08f23a2fd2e3124b1d2
)

vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/gettext/bin")

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSES/LGPL-2.1-or-later.txt")
