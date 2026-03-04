# ============================================================================
#  TinyGNN vcpkg port  —  portfile.cmake
#  v0.1.4  SHA512 computed from https://github.com/AnubhavChoudheries/TinyGNN/archive/v0.1.4.tar.gz
# ============================================================================

# TinyGNN does not annotate public symbols with __declspec(dllexport), so a
# shared-library build on Windows produces DLLs with zero exports.
# Force static linkage to avoid that and to keep the install layout simple.
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AnubhavChoudhery/TinyGNN
    REF "v${VERSION}"
    SHA512 9fa6fc5d57efc898433791d579296659511147b30454215b553b7a9ef52697dff4eb33e8e1db29f4087c698d648e20801e8d063f63f06926e61ce80a78152229
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTINYGNN_BUILD_TESTS=OFF
        -DTINYGNN_BUILD_BENCHMARKS=OFF
        -DBUILD_SHARED_LIBS=OFF
)

vcpkg_cmake_install()

# Move the CMake config files from datadir → share/<port> (vcpkg convention)
vcpkg_cmake_config_fixup(PACKAGE_NAME tinygnn CONFIG_PATH share/tinygnn)

# Remove the debug include tree (headers are not debug-specific)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Install usage instructions shown after vcpkg install
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Install license (vcpkg requires a file named 'copyright')
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
