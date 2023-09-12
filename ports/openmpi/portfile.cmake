vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(OpenMPI_FULL_VERSION "4.1.3")
set(OpenMPI_SHORT_VERSION "4.1")

vcpkg_download_distfile(ARCHIVE
  URLS "https://download.open-mpi.org/release/open-mpi/v${OpenMPI_SHORT_VERSION}/openmpi-${OpenMPI_FULL_VERSION}.tar.gz"
  FILENAME "openmpi-${OpenMPI_FULL_VERSION}.tar.gz"
  SHA512 f7b177121863ef79df6106639d18a89c028442b1314340638273b12025c4dc2cf9b5316cb7e6ecca8b65a51ee40a306a6b0970d7cce727fbb269a14f89af3161
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

vcpkg_configure_make(
        COPY_SOURCE
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            --with-hwloc=internal
            --with-libevent=internal
            --disable-mpi-fortran
        OPTIONS_DEBUG
            --enable-debug
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
