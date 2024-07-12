# Manually clone the repository with submodules
# Pull it from artifacts
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/3MFConsortium/lib3mf/releases/download/v2.3.2/lib3mf-2.3.2-source-with-submodules.zip"
    FILENAME "lib3mf-2.3.2-source-with-submodules.zip"
    SHA512 222821e4d739a3277b96977ec656a6498e75d19e62a34cd7cf204ef388643d2cfc1610f38abe9f8c60a4c450248f3a4de39822c367b6cbb405d43148d32d52d2
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

# Fix the path issue for CMake config files
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/lib3mf)

# Fix up package configs (Get rid of absolute paths)
vcpkg_fixup_pkgconfig()

# Install the license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Install the usage file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Remove some of the debug stuff
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
