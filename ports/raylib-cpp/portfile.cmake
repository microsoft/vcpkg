set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RobLoach/raylib-cpp
    REF "v${VERSION}"
    SHA512 12da247a1c1a3e0bc2d9f8c361024983b4cbcefe17c0d288e29593c8d49d44e8d319acda91c13fb181a933de9535d61ee75f3a2bf8549dcb3986f21c5d8a7e44
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
