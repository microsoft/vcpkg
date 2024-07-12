# Manually clone the repository with submodules
set(REPO_URL "https://github.com/3MFConsortium/lib3mf.git")
set(COMMIT_HASH "release/2.3.2")  # Replace with your specific commit hash or branch name

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/lib3mf/src)

execute_process(
    COMMAND git clone --recurse-submodules ${REPO_URL} ${SOURCE_PATH}
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
)

execute_process(
    COMMAND git checkout ${COMMIT_HASH}
    WORKING_DIRECTORY ${SOURCE_PATH}
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
