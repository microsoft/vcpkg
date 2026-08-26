vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-dis/open-dis-cpp
    REF "v${VERSION}"
    SHA512 54d46ba71b67af8710d2f15c42ed28f90ea31fb90edcdf0cc8ec099339648fe3cfa0faac4754c863332a24b01c3f6554d2a978e0ecfe8e4e0484fce78fbf45df
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_OPENDIS6=ON
        -DBUILD_OPENDIS7=ON
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(PACKAGE_NAME OpenDIS CONFIG_PATH lib/cmake/OpenDIS)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
