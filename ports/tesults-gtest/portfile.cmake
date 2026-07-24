set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tesults/tesults-gtest
    REF "v${VERSION}"
    SHA512 674f8c10e02b77e7c00ac9188651eb1c3be5d649cda029b3b577a5d2c4ede58521b04620354b9032d3892a8a704a59047b6de0c293d9705a575b4ba437cb8682
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/tesults-gtest)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
