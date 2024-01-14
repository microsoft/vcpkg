vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LTLA/umappp
    REF d18095ea8b6d62aa740a566411e439eaab16b71f
    SHA512 5f05c9cd7eeac2c16e8dbb0e747c84bc5209e91e37cf8a120273b01f681e19afa69d52e03a6862386c75d9f4d62d925135087c69b835257764aa1f490d92ef3d
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
    PACKAGE_NAME ltla_umappp
    CONFIG_PATH lib/cmake/ltla_umappp
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
