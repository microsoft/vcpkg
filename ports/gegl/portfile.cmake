string(REGEX MATCH [[^[0-9][0-9]*\.[1-9][0-9]*]] VERSION_MAJOR_MINOR ${VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS https://download.gimp.org/pub/gegl/${VERSION_MAJOR_MINOR}/gegl-${VERSION}.tar.xz
    FILENAME "gegl-${VERSION}.tar.xz"
    SHA512 9f47480dc2fad58c052aa3df3ac914d500614e7acb0dc46677bea4228350a00a0fe38b5b0572303251210e3e544b5b7cb51415476586630df4da8f4b7c6486d8
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        disable_tests.patch
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
