vcpkg_download_distfile(ARCHIVE
    URLS "https://download.gimp.org/gimp/v3.2/gimp-${VERSION}-RC2.tar.xz"
    FILENAME "gimp-${VERSION}.tar.xz"
    SHA512 b6b201b4f76966f96ab201761a61b4040907d31850c8786d3824d9aac14f04ae53697b74e5c9fee69640c4843fc1b7810a8990b19ba3d7a8131d8783aa5b6d0b
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        glib_networking.patch
        gio.patch
)

set(ENV{PKG_CONFIG_PATH} "${CURRENT_INSTALLED_DIR}/lib/pkgconfig")
set(ENV{BABL_PATH} "${CURRENT_INSTALLED_DIR}/debug/lib/babl-0.1:${CURRENT_INSTALLED_DIR}/lib/babl-0.1")
set(ENV{GEGL_PATH} "${CURRENT_INSTALLED_DIR}/debug/lib/gegl-0.4:${CURRENT_INSTALLED_DIR}/lib/gegl-0.4")
set(ENV{GI_TYPELIB_PATH} "${CURRENT_INSTALLED_DIR}/lib/girepository-1.0/")
set(ENV{FONTCONFIG_PATH} "${CURRENT_INSTALLED_DIR}/share/fontconfig/conf.avail")
vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/gettext/bin")
vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/gtk3")
vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/gdk-pixbuf")

vcpkg_get_gobject_introspection_programs(PYTHON3 GIR_COMPILER GIR_SCANNER)

execute_process(
  COMMAND "${PYTHON3}" "-m" "pip" "install" "PyGObject"
  RESULT_VARIABLE python_exit_code
  OUTPUT_VARIABLE python_stdout
  ERROR_VARIABLE python_stderr
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

if(NOT python_exit_code EQUAL 0)
  message(FATAL_ERROR "Python failed: ${python_stderr}")
endif()

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
        -Dvector-icons=true
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
