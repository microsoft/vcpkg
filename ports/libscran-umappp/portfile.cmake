vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libscran/umappp
    REF "v${VERSION}"
    SHA512 e1eb144b7b3a28b419d2d8645a3b5c8ff003fb9b67bb566a238c692b3d44580712f3dfb57ac3d4ed1cc5244b3e1fefb90d7449e0dfd41ded9401d5d6fe20ef20
    HEAD_REF master
    PATCHES
        0001-make-find-dependency-not-required.diff # https://github.com/libscran/umappp/pull/35
        0002-remove-eigen3-version-constraint.diff
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUMAPPP_FETCH_EXTERN=OFF
        -DUMAPPP_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME libscran_umappp
    CONFIG_PATH lib/cmake/libscran_umappp
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
