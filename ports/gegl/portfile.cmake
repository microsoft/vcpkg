string(REGEX MATCH [[^[0-9][0-9]*\.[1-9][0-9]*]] VERSION_MAJOR_MINOR ${VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS https://download.gimp.org/pub/gegl/${VERSION_MAJOR_MINOR}/gegl-${VERSION}.tar.xz
    FILENAME "gegl-${VERSION}.tar.xz"
    SHA512 94bdc545a7647491adb6371779ce128d5d03120ae58c849bd76cd2acaab58fd00a0579ce28f0e46d4c171a1f2796ab09d4633c24bd01eabd8b959400cbe6e650
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        disable_tests.patch
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
