vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uni-algo/uni-algo
    REF "v${VERSION}"
    SHA512 031d6ec2a1a2c09972a68d7b9bf49a209441e69802d5d8d37b2a37d9b6e002427496d420629d2119dc1d0e80f38c7b220e253b0858db5f172789472447041799
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        header-only UNI_ALGO_HEADER_ONLY
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DUNI_ALGO_INSTALL=ON
)

vcpkg_cmake_install()

# The library uses share/uni-algo/cmake for CMake targets,
# but prefix correction seems to expect only share/uni-algo
# and breaks paths if not disabled, it's not needed anyway.
vcpkg_cmake_config_fixup(NO_PREFIX_CORRECTION)

# Copy .pdb to .dll files on Windows
vcpkg_copy_pdbs()

# Remove useless duplicated include in debug directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
# Remove empty directories
if(UNI_ALGO_HEADER_ONLY)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/uni_algo/impl/doc")

# Install copyright and usage
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
