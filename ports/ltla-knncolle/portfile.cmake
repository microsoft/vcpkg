vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LTLA/knncolle
    REF 3ad6b8cdbd281d78c77390d5a6ded4513bdf3860
    SHA512 c6e66d8ea5501cb511fd88155d18b57b31661ad0e20f3289d9a7ec8fc558f91dd409487b53d41171111fdaa2baa11fe9548f01daf307a90121d17dc398203676
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKNNCOLLE_FETCH_EXTERN=OFF
        -DKNNCOLLE_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME ltla_knncolle
    CONFIG_PATH lib/cmake/ltla_knncolle
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
