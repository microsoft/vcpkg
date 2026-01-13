vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nholthaus/units
    REF v${VERSION}
    SHA512 9cedc52e0405140b9a8014195f59f4deb2edd155fe78df76005eb721974c2a640975d9b959777be48f41c24f6a0a7047536649958da847e2aa8b0c3b9a6d139a
)

set(VCPKG_BUILD_TYPE "release")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUNITS_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/units)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")  # from CMake config

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
