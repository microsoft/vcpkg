set(VCPKG_BUILD_TYPE release)  # header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MistEO/meojson
    REF v4.5.0
    SHA512 f3e85f6a51a8dc3a7e9c11eb5e30553ecc7cec64a50e1acbce7ca7f2aaba76ab25bc7eb6575625b4294975142a3aefe9d9d6f4e147242f73192e934fc7be849a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SAMPLE=OFF
        -DBUILD_TESTING=OFF
        -DBUILD_BENCHMARK=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/meojson)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
