set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RobLoach/raylib-cpp
    REF "v${VERSION}"
    SHA512 db7e4eef3756b95fdcd583e0485d006311173a96f59c3aed6bda1b07bcae5c6d7c1ab7fda51220edfd1b170c6b1622f3f6bf5de7cececaa172c5f0bdf8fcdf72
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
