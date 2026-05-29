set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RobLoach/raylib-cpp
    REF "v${VERSION}"
    SHA512 7627e84e56b234f9ada28d0b7c7d39c6a6289d3c2cdbd0e87e71743c2897dfb1e80bb32c60d92fdb5a89e4f09a827fa9919c7f983aa00e9ad0d8e9c03ba49cd5
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_RAYLIB_CPP_EXAMPLES=OFF
)
vcpkg_cmake_install()

# Keep root include clean
file(RENAME "${CURRENT_PACKAGES_DIR}/include" "${CURRENT_PACKAGES_DIR}/raylib-cpp")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(RENAME "${CURRENT_PACKAGES_DIR}/raylib-cpp" "${CURRENT_PACKAGES_DIR}/include/raylib-cpp")
file(WRITE "${CURRENT_PACKAGES_DIR}/include/raylib-cpp.hpp" "#include \"raylib-cpp/raylib-cpp.hpp\"\n")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
