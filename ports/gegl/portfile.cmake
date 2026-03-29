string(REGEX MATCH [[^[0-9][0-9]*\.[1-9][0-9]*]] VERSION_MAJOR_MINOR ${VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS https://download.gimp.org/pub/gegl/${VERSION_MAJOR_MINOR}/gegl-${VERSION}.tar.xz
    FILENAME "gegl-${VERSION}.tar.xz"
    SHA512 e13b1885b0cd6aa439cdb7c1d56b81c754d41da1af6ed17eab3e1beb7b7fe74094e0da9d8bacaea9ec5d4ec95eea682cf4764ea828bda4a7d7acec9b273c537e
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
