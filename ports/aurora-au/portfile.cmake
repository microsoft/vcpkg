set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aurora-opensource/au
    REF "${VERSION}"
    SHA512 4aa3282f6b76fbadd04ca572734f72c86b1b0b4e85fc21a03d1ab00b83d3aea319ab2dac3934361b5f6fa7c4a0dccece94fe0a57f3d73d208315b51b1950e374
    HEAD_REF main
    PATCHES 
        disable-googletest.patch
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/Au
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")  # Remove empty directory
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
