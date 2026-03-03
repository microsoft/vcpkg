vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libscran/umappp
    REF "v${VERSION}"
    SHA512 a4706321d6129194520e909b7978b297cb114dffe7a3a449960cf1c3f06ca1dc1903ca8f1a23c924706d9fc44e3af7479f9fac05b3d5f710414b37b0cca9fdf6
    HEAD_REF master
    PATCHES
        0001-fix-eigen3-dependency.patch
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
