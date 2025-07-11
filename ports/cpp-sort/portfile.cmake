set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Morwenn/cpp-sort
    REF "${VERSION}"
    SHA512 4ddb37e5724b0cf6f0889c889bc6a96f272f5eea1bf1ae151888d456b6a77fa64a2b887a8c8c7c42f2d0c77203c951e67a8358eed9694612e377e7233aef6c04
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
