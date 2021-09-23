vcpkg_fail_port_install(ON_TARGET "Windows" "UWP")

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(OpenMPI_FULL_VERSION "4.1.0")
set(OpenMPI_SHORT_VERSION "4.1")

vcpkg_download_distfile(ARCHIVE
  URLS "https://download.open-mpi.org/release/open-mpi/v${OpenMPI_SHORT_VERSION}/openmpi-${OpenMPI_FULL_VERSION}.tar.gz"
  FILENAME "openmpi-${OpenMPI_FULL_VERSION}.tar.gz"
  SHA512 1f8117b11c5279d34194b4f5652b0223cf1258a4ac0efd40bab78f31f203068e027235a92a87e546b1b35c5b369bc90788b109c05a7068c75533a03649410e99
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
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

vcpkg_install_make(DISABLE_PARALLEL)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
