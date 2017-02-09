
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libepoxy-2432daf4cf58b5ff11e008ca34811588285c43b3)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/anholt/libepoxy/archive/2432daf4cf58b5ff11e008ca34811588285c43b3.zip"
    FILENAME "libepoxy-2432daf4cf58b5ff11e008ca34811588285c43b3.zip"
    SHA512 70b59b6c5722eb87522927fdedab44f74ffd2d71d2ae42509de07b0c3e13f71320b25da0d4c75dca75c4208ea7a525483267d6ccb8acd5274728c015c7ac4006)

vcpkg_extract_source_archive(${ARCHIVE})

# ensure python is on path - not for meson but some source geneation scripts
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_PATH ${PYTHON3} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PYTHON3_PATH}")

vcpkg_configure_meson(SOURCE_PATH ${SOURCE_PATH})
vcpkg_install_meson()

vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libepoxy)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libepoxy/COPYING ${CURRENT_PACKAGES_DIR}/share/libepoxy/copyright)
