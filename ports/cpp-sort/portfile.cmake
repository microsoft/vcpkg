set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Morwenn/cpp-sort
    REF "v${VERSION}"
    SHA512 4a81dc92f8b386a6c6303fa9f4787e9b214a79c342dad3dff1b876d0daf251e74b0ab94a068dcca0eeec838d19bc6b7ee1e777b9ee748cfd4a81aa7159e4fe14
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
