# Pull it from artifacts
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/vijaiaeroastro/3mfExamples/releases/download/2.3.1/lib3mf-2.3.0-cmake-complete.zip"
    FILENAME "lib3mf-2.3.0-vijai-develop.zip"
    SHA512 8dfb9a9e292f4fa5d6d222c9940408ac267f2ef1a9e35c00412e02a7ba6d8823d66594070d8b4d9c32ff7638d2e0ad0fcba586968c9fa8c017b8a610ce145feb
)

# Extract it
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

# Proceed with the usual build process
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DLIB3MF_TESTS=OFF
)

# Install the package
vcpkg_cmake_install()

# Copy all PDB's
vcpkg_copy_pdbs()

# This should help fix the path issue for CMake config files
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/lib3mf)

# Fix up package configs (Get rid of absolute paths)
vcpkg_fixup_pkgconfig()

# Install the license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Remove some of the debug stuff
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")