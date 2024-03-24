include(vcpkg_find_fortran)
vcpkg_find_fortran(FORTRAN)

vcpkg_find_acquire_program(BISON)
get_filename_component(BISON_EXE_PATH "${BISON}" DIRECTORY)
vcpkg_add_to_path("${BISON_EXE_PATH}")

vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_EXE_PATH "${FLEX}" DIRECTORY)
vcpkg_add_to_path("${FLEX_EXE_PATH}")

vcpkg_find_acquire_program(GPERF)
get_filename_component(GPERF_EXE_PATH "${GPERF}" DIRECTORY)
vcpkg_add_to_path("${GPERF_EXE_PATH}")

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftpmirror.gnu.org/octave/octave-${VERSION}.tar.xz"
    FILENAME "octave-${VERSION}.tar.xz"
    SHA512 95799fc3f8217b11316926570874bf0e25cdac8cead416ae000ecfeba2643d3a688c015fa07935671a9f8a338f2f070ea75d452a36b295400f177c5a13890905
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
)

vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}/bin")
vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}/debug/bin")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
    --disable-docs
    --without-hdf5
)

vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/octave/site/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/octave/site/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/octave/site/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/octave/${VERSION}/site/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/octave/${VERSION}/site/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/libexec/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/libexec")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/octave/octave/${VERSION}/site")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/octave/octave/site")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

vcpkg_fixup_pkgconfig()
