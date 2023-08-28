vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/datasketches-cpp
    REF "${VERSION}"
    SHA512 81047ec2ac4559afc46d68b2332256b3950fc7092404606a872d9204c7e0ac13b7b0e0d6a34de01483bcb03c813ab75ce4866cc0c6783ebf4adddaa6535d322a
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME DataSketches CONFIG_PATH lib/DataSketches/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
