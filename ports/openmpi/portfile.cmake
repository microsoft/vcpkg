vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

string(REGEX REPLACE [[^([0-9]+[.][0-9]+).*$]] [[\1]] OpenMPI_SHORT_VERSION "${VERSION}")

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.open-mpi.org/release/open-mpi/v${OpenMPI_SHORT_VERSION}/openmpi-${VERSION}.tar.gz"
    FILENAME "openmpi-${VERSION}.tar.gz"
    SHA512 25eb96116126641cd1c8fdccbd3c4b40cbdd7b1e8709ff629c6fca9ee58b566983e00e829c724952fca685a8d321b4dddf8691df08693a2ffee5f05b30e08058
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        keep_isystem.patch
)

vcpkg_find_acquire_program(PERL)
cmake_path(GET PERL PARENT_PATH PERL_PATH)
vcpkg_add_to_path("${PERL_PATH}")

# Put wrapper data dir side-by-side to wrapper executables dir instead of loosing debug data.
# VCPKG_CONFIGURE_MAKE_OPTIONS overwrites vcpkg_configure_make overwrites OPTIONS.
vcpkg_list(PREPEND VCPKG_CONFIGURE_MAKE_OPTIONS_DEBUG [[--datadir=\${prefix}/../tools/openmpi/debug/share]])
vcpkg_list(PREPEND VCPKG_CONFIGURE_MAKE_OPTIONS_RELEASE [[--datadir=\${prefix}/tools/openmpi/share]])
if(VCPKG_TARGET_IS_OSX)
    # This ensures that vcpkg-fixup-macho-rpath succeeds
    string(APPEND VCPKG_LINKER_FLAGS " -headerpad_max_install_names")
endif()

vcpkg_make_configure(
    COPY_SOURCE
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --disable-dependency-tracking
        --with-hwloc=internal
        --with-libevent=internal
        --with-pmix=internal
        --disable-mpi-fortran
    OPTIONS_DEBUG
        --enable-debug
)
vcpkg_make_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

configure_file("${CURRENT_PORT_DIR}/mpi-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/mpi-wrapper.cmake" @ONLY)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
