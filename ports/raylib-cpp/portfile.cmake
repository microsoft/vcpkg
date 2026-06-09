set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RobLoach/raylib-cpp
    REF "v${VERSION}"
    SHA512 a8a2b54c21811b5181e485420bb932a94b2fe14252e203dd5f3a60c4a9f5937f5d5b519fa7e1953a3e100f76e94da687d75953493041fbbfcfe4baff46d2e57a
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
