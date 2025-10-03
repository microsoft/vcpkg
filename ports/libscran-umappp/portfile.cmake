vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libscran/umappp
    REF "v${VERSION}"
    SHA512 cb934d4989c63485d457423419dc749b5d775f800d8a0bee65566b5f5def00ce1720eb583cb1e5bd277bc04b9cd0f31a4b1b2cd65f50ac2564a1970b00e42d16
    HEAD_REF master
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
