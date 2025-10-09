vcpkg_from_gitlab(
    GITLAB_URL "https://gitlab.gnome.org"
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "GNOME/libnotify"
    REF "${VERSION}"
    HEAD_REF "master"
    SHA512 731f874676347e18b45eb63ae6a968bce8b34d57aadef444733b73a51b3b29297751699f3aeae9dfd2779afffc7e9c15d3a4141504cfe6cd46f51f79d3ee85d5
    PATCHES
        0001-fix-parameter-name-omitted-error.patch
)

vcpkg_list(SET RELEASE_OPTIONS)
if("introspection" IN_LIST FEATURES)
    vcpkg_list(APPEND RELEASE_OPTIONS -Dintrospection=enabled)
    vcpkg_get_gobject_introspection_programs(PYTHON3 GIR_COMPILER GIR_SCANNER)
else()
    vcpkg_list(APPEND RELEASE_OPTIONS -Dintrospection=disabled)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dtests=false
        -Dman=false
        -Dgtk_doc=false
        -Ddocbook_docs=disabled
    OPTIONS_RELEASE
        ${RELEASE_OPTIONS}
    OPTIONS_DEBUG
        -Dintrospection=disabled
    ADDITIONAL_BINARIES
        "g-ir-compiler='${GIR_COMPILER}'"
        "g-ir-scanner='${GIR_SCANNER}'"
        "glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'"
        "glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'"
)

vcpkg_install_meson()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
