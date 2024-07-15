# Manually clone the repository with submodules
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/3MFConsortium/lib3mf/archive/refs/tags/v2.3.2.zip"
    FILENAME "lib3mf-2.3.2.zip"
    SHA512 5bf888c06a2429bfaca45b5ed96b2a7077a84ca3d1c4d114967eca0798189d9cbe7454eb810dcc18ccf31561efca271c4f68e7666f9f2665a8592df530f0d0bb
)

# Extract it
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

# Apply the patch
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "lib3mf_vcpkg.patch"
)

# Only dynamic libraries (Based on Jan's Port)
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

# Proceed with the usual build process
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
    -DUSE_INCLUDED_ZLIB=OFF
    -DUSE_INCLUDED_LIBZIP=OFF
    -DUSE_INCLUDED_BASE_64=OFF
    -DUSE_INCLUDED_FAST_FLOAT=OFF
    -DUSE_INCLUDED_SSL=OFF
    -DBUILD_FOR_CODECOVERAGE=OFF
    -DLIB3MF_TESTS=OFF
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