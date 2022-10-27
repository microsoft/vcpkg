#vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
#set(VCPKG_FIXUP_ELF_RPATH ON)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mesa/glu
    REF cbbff8857e49c5e4615e2f8e21dd18cc6317c252
    SHA512 b4e928413ac0d8a6e8dec4781425526f5fad42588fa52b7e41ff42d1925084586367ba580004930c58697af899c1cf468666b20e4037be0e36fce1827f91c484
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(TOUCH "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
