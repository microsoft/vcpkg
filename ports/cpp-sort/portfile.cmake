set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Morwenn/cpp-sort
    REF "v${VERSION}"
    SHA512 4567092dd03f37d61cc5b315954de8c867b74d5831d1843814514f8c6cccdb134646a0287bb85e7dd7b60410971f9587e48af2b6e4fb67b555732ba91103ec10
    HEAD_REF 1.x.y-develop
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCPPSORT_BUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/cpp-sort")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
