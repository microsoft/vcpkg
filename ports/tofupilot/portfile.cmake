vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tofupilot/cpp
    REF v${VERSION}
    SHA512 733ed3489162ca339586a5d2ba069d974e5bbe44f59c6ef135266827386d66d0cf6b98bcca2274752c1b490f95ca4647474236d9a7bbe34a5b8c33572389fd23
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME tofupilot CONFIG_PATH lib/cmake/tofupilot)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
