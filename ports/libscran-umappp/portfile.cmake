vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libscran/umappp
    REF "v${VERSION}"
    SHA512 12372dc0462e5f444d3e54eb07c370a3eb8190d7c9b716788fe214d2043b55844fe6e86ebd09120cb66f1b672be9a168a9b34b585eacc291210d4600e55795d6
    HEAD_REF master
    PATCHES
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
