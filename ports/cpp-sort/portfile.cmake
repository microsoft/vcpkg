vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Morwenn/cpp-sort
    REF "${VERSION}"
    SHA512 85d9f68ff64ff23769c66d28153273e2072b2c12f2f94bb058afebc1fb68d852734d3907a51704212d795bff71f327de3497232ba3619179bbaa141ab55b2452
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
