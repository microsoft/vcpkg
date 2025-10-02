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
    MAYBE_UNUSED_VARIABLES
        BUILD_TESTING
)

vcpkg_cmake_install()

# Header-only library, so remove directories that aren't needed
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)