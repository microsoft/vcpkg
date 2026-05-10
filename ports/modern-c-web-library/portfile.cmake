vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kamrankhan78694/modern-c-web-library
    REF v1.0.0
    SHA512 46797a93f9fbc1f15612fa9d2187675ec368f2346b216725765d26eefbfef3aa0330ea40c7f620c850dca05c199c07facfd0089ca152ac62e1708c7045e10edc
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

# Remove debug include directory to satisfy policy (headers identical)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Install usage file
file(COPY "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
