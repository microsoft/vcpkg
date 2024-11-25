add set(VCPKG_POLICY_ALLOW_DEBUG_INCLUDE enabled)
set(VCPKG_POLICY_SKIP_MISPLACED_CMAKE_FILES_CHECK enabled)
add set(VCPKG_POLICY_SKIP_LIB_CMAKE_MERGE_CHECK enabled)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO elalish/manifold
    REF v3.0.0
    SHA512 881d3b0e3ff03794ce66b09c4a7be675e5dcd5d5b269d62ad5c5de177e76a01460f6f0fb55a2973a92abda3bf32b8a08bafdff5c0b379ae095d9806eb5669022
)

# Configure the project
vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DMANIFOLD_DEBUG=OFF
        -DMANIFOLD_TEST=OFF  # Disable tests to avoid overhead
        -DMANIFOLD_CROSS_SECTION=ON  # Enable cross-section support
        -DMANIFOLD_CBIND=ON  # Enable C bindings
        -DMANIFOLD_PYBIND=OFF  # Enable Python bindings
        -DMANIFOLD_JSBIND=OFF  # Disable JS bindings
    OPTIONS_RELEASE
        -DMANIFOLD_DEBUG=OFF
    OPTIONS_DEBUG
        -DMANIFOLD_DEBUG=ON
)

# Build and install
vcpkg_cmake_build()
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
