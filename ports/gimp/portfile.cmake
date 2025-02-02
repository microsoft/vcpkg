vcpkg_download_distfile(ARCHIVE
    URLS "https://download.gimp.org/gimp/v3.2/gimp-${VERSION}-RC2.tar.xz"
    FILENAME "gimp-${VERSION}.tar.xz"
    SHA512 7a83768caae458b75883522c87d5297e9642b64b0516c482804034b8b9acc6af6afc89d1b4a549fd26de3e33816136c31d440f554f66669c8ccd43536260916a
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        glib_networking.patch
        bzip2.patch
        gir_share.patch
)

vcpkg_get_gobject_introspection_programs(PYTHON3 GIR_COMPILER GIR_SCANNER)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Daa=disabled
        -Dalsa=disabled
        -Dappdata-test=disabled
        -Dcairo-pdf=disabled
        -Dfits=disabled
        -Dghostscript=disabled
        -Dgudev=disabled
        -Dheif=disabled
        -Dilbm=disabled
        -Djpeg2000=disabled
        -Djpeg-xl=disabled
        -Dmng=disabled
        -Dopenexr=disabled
        -Dopenmp=disabled
        -Dprint=false
        -Dwebkit-unmaintained=false
        -Dwebp=disabled
        -Dwmf=disabled
        -Dxcursor=disabled
        -Dxpm=disabled
        -Dheadless-tests=disabled
        -Dfile-plug-ins-test=false
        -Dcan-crosscompile-gir=false
        -Dgi-docgen=disabled
        -Dlinux-input=disabled
        -Dvector-icons=false
        -Dvala=disabled
        -Djavascript=disabled
        -Dlua=false
        -Ddebug-self-in-build=false
    ADDITIONAL_BINARIES
        "g-ir-compiler='${GIR_COMPILER}'"
        "g-ir-scanner='${GIR_SCANNER}'"
)

vcpkg_install_meson()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
