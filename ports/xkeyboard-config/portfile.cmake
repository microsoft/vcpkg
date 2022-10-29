# Get source code:
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xkeyboard-config/xkeyboard-config
    REF  b5f7adf3fd85b90c1fd5d85186ea5cb0d5db69be
    SHA512 363e29f5f1d6c39d4340585ded3c2badad74a0147cdbdfc43164ded7b68d9c115934e9b4b3b066e0e94300b070e08cea53f75a22bd7afdc5f84f66ad91d47e03
    HEAD_REF master # branch name
) 

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -Dxorg-rules-symlinks=false
            -Dxkb-base=$datadir/xkbcomp/X11/xkb
)
vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_PATH "${PERL}" DIRECTORY)
vcpkg_add_to_path("${PERL_PATH}")
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

