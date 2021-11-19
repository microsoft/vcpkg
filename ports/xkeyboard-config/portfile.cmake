# Get source code:
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xkeyboard-config/xkeyboard-config
    REF  b5f7adf3fd85b90c1fd5d85186ea5cb0d5db69be
    SHA512 2a4cc13507401858e469333805471367a75697716ecae542a212696cc5c556999f6f18bc0fd3ec436065ed7419b1cd40251bcb8acb6932e75adb70de046fa776
    HEAD_REF master # branch name
) 

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -Dxorg-rules-symlinks=false
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

