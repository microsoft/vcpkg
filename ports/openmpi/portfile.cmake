vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

string(REGEX REPLACE [[^([0-9]+[.][0-9]+).*$]] [[\1]] OpenMPI_SHORT_VERSION "${VERSION}")

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.open-mpi.org/release/open-mpi/v${OpenMPI_SHORT_VERSION}/openmpi-${VERSION}.tar.gz"
    FILENAME "openmpi-${VERSION}.tar.gz"
    SHA512 34d8db42b93d79f178fea043ff8b5565e646b4935be6fa57fff6674030e901b4c84012c800304a6ce639738beb04191fe78a9372eae626dd4a2f8c0839711e46
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        keep_isystem.patch
)

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_PATH})

# Put wrapper data dir side-by-side to wrapper executables dir instead of loosing debug data.
# VCPKG_CONFIGURE_MAKE_OPTIONS overwrites vcpkg_configure_make overwrites OPTIONS.
vcpkg_list(PREPEND VCPKG_CONFIGURE_MAKE_OPTIONS_DEBUG [[--datadir=\${prefix}/../tools/openmpi/debug/share]])
vcpkg_list(PREPEND VCPKG_CONFIGURE_MAKE_OPTIONS_RELEASE [[--datadir=\${prefix}/tools/openmpi/share]])

vcpkg_configure_make(
        COPY_SOURCE
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            --with-hwloc=internal
            --with-libevent=internal
            --with-pmix=internal
            --disable-mpi-fortran
        OPTIONS_DEBUG
            --enable-debug
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CURRENT_PORT_DIR}/mpi-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
