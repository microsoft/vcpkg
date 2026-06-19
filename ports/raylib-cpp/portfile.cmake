set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RobLoach/raylib-cpp
    REF "v${VERSION}"
    SHA512 671f31b662a459df741286d2268d4ffa5a6b9e8205313e2aa6c37a1775473022a3339af9e6685789883be07d3c67751da43ca7978d0d5034e0148aa818c27efc
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
