string(REGEX MATCH [[^[0-9][0-9]*\.[1-9][0-9]*]] VERSION_MAJOR_MINOR ${VERSION})

vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://gitlab.gnome.org/
    REPO GNOME/gegl
    REF bf52f2e6daa3c0c3ed9e45f2aa6e70109144e030
    SHA512 15cbfeb3574fd404f609527939567ce0a3fb7efd50426bed4c7d7077b2cef54d4ec9840cad7c2b3098bea79f43682695830e37b6bf21f11d8752bf85800dfa33
    PATCHES
        disable_tests.patch
        use-plugins-dir.patch
        remove_execinfo_support.patch
        remove-consistency-check.patch
)

if("introspection" IN_LIST FEATURES)
    list(APPEND feature_options "-Dintrospection=true")
    vcpkg_get_gobject_introspection_programs(PYTHON3 GIR_COMPILER GIR_SCANNER)
else()
    list(APPEND feature_options "-Dintrospection=false")
endif()

if("cairo" IN_LIST FEATURES)
    list(APPEND feature_options "-Dcairo=enabled")
else()
    list(APPEND feature_options "-Dcairo=disabled")
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${feature_options}
        -Ddocs=false
        -Dgdk-pixbuf=disabled
        -Dgexiv2=disabled
        -Dgraphviz=disabled
        -Djasper=disabled
        -Dlcms=disabled
        -Dlensfun=disabled
        -Dlibav=disabled
        -Dlibraw=disabled
        -Dlibrsvg=disabled
        -Dlibspiro=disabled
        -Dlibtiff=disabled
        -Dlibv4l=disabled
        -Dlibv4l2=disabled
        -Dlua=disabled
        -Dmrg=disabled
        -Dmaxflow=disabled
        -Dopenexr=disabled
        -Dopenmp=disabled
        -Dpango=disabled
        -Dpangocairo=disabled
        -Dpoppler=disabled
        -Dpygobject=disabled
        -Dsdl2=disabled
        -Dumfpack=disabled
        -Dwebp=disabled
    ADDITIONAL_BINARIES
        "g-ir-compiler='${GIR_COMPILER}'"
        "g-ir-scanner='${GIR_SCANNER}'"
)

vcpkg_install_meson()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(
    TOOL_NAMES gegl gegl-imgcmp
    AUTO_CLEAN
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
