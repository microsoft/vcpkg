vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libscran/umappp
    REF "v${VERSION}"
    SHA512 c187ccd520d5304726ea75a38a040a37bb46e04bb5b51bf3deb0abb11fb2b97dac577057c1673af196ddb6f9eec2f1d8a944a58a108db7fe871dc14bfeb8fb61
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
