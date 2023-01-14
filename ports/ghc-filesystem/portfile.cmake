vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gulrak/filesystem
    REF v1.5.10
    HEAD_REF master
    SHA512 470dd9e1c4358f9d8d9f531d8c3c6716cdd156c815315748436a1dc3caf095d320e58eae2274df8c15e293cc96170752fb00aed8ad2210d417b174c13297fbac
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGHC_FILESYSTEM_BUILD_TESTING=OFF
        -DGHC_FILESYSTEM_BUILD_EXAMPLES=OFF
        -DGHC_FILESYSTEM_WITH_INSTALL=ON
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME ghc_filesystem
    CONFIG_PATH lib/cmake/ghc_filesystem
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
