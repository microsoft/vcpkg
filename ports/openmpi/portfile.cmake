vcpkg_fail_port_install(ON_TARGET "Windows" "UWP")

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(OpenMPI_FULL_VERSION "4.0.3")
set(OpenMPI_SHORT_VERSION "4.0")

vcpkg_download_distfile(ARCHIVE
  URLS "https://download.open-mpi.org/release/open-mpi/v${OpenMPI_SHORT_VERSION}/openmpi-${OpenMPI_FULL_VERSION}.tar.gz"
  FILENAME "openmpi-${OpenMPI_FULL_VERSION}.tar.gz"
  SHA512 23a9dfb7f4a63589b82f4e073a825550d3bc7e6b34770898325323ef4a28ed90b47576acaae6be427eb2007b37a88e18c1ea44d929b8ca083fe576ef1111fef6
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
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
        OPTIONS_DEBUG
            --enable-debug
)

vcpkg_install_make(DISABLE_PARALLEL)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
