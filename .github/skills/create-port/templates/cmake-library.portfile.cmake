vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO {{GITHUB_REPO}}
    REF "{{VERSION}}"
    SHA512 {{SHA512_PLACEHOLDER}}
    HEAD_REF {{HEAD_REF}}
    # Uncomment the following if patches are needed
    # PATCHES
    #     fix-cmakelists.patch
    #     fix-config.patch
)

# Uncomment and configure if the package supports features
# vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
#     FEATURES
#         feature1    ENABLE_FEATURE1
#         feature2    ENABLE_FEATURE2
# )

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        {{CMAKE_OPTIONS}}
        # Disable non-essential components by default
        -DBUILD_TESTING=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_SAMPLES=OFF
        -DBUILD_DOCS=OFF
        -DBUILD_DOC=OFF
        -DBUILD_DOCUMENTATION=OFF
        # ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

# Fix CMake config files for proper target exports
vcpkg_cmake_config_fixup(
    {{CMAKE_CONFIG_PATH}}
    # PACKAGE_NAME {{PACKAGE_NAME}}
    # CONFIG_PATH lib/cmake/{{PACKAGE_NAME}}
)

# Fix pkg-config files if they exist
vcpkg_fixup_pkgconfig()

# Copy pdbs for debugging on Windows
vcpkg_copy_pdbs()

# Remove duplicate files from debug directory
file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

# Install copyright/license file
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/{{LICENSE_FILE}}")

