# Pull it from artifacts
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/vijaiaeroastro/3mfExamples/releases/download/2.3.1/lib3mf-2.3.0-vijai-develop.zip"
    FILENAME "lib3mf-2.3.0-vijai-develop.zip"
    SHA512 a43e1c685e0b72241ae0573becbaca1ac21177b65fa305e0add761c0a0670b6c224041492b7ce1f84e1838bc62e4a89ea94477ea45e0127c8272f1b30698fa48
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