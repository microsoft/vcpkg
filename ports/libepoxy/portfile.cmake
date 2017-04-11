if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libepoxy-7d58fd3d47d2d69f2b1b9f08325302e4eeff9ebe)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/anholt/libepoxy/archive/7d58fd3d47d2d69f2b1b9f08325302e4eeff9ebe.zip"
    FILENAME "libepoxy-7d58fd3d47d2d69f2b1b9f08325302e4eeff9ebe.zip"
    SHA512 7e97a7832ea136565be92d6f6f0afead2fff9ac7b2999ef9e7865ac18dfbeab354e5a652b1a86e982a323dca9a1446df07821c26d315b7da4ca72b5be7345695)

vcpkg_extract_source_archive(${ARCHIVE})

# ensure python is on path - not for meson but some source generation scripts
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_PATH ${PYTHON3} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PYTHON3_PATH}")

vcpkg_configure_meson(SOURCE_PATH ${SOURCE_PATH})
vcpkg_install_meson()

vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libepoxy)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libepoxy/COPYING ${CURRENT_PACKAGES_DIR}/share/libepoxy/copyright)
