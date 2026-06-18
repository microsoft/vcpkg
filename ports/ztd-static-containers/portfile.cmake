vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO soasis/static_containers
    REF e1a21217b6dba3028e6cc6bf0f9562972ea1c43d
    SHA512 b108b1e206854ddb4ceed9780c89c8db717c87bd010ee5ff1f176b79a26192dcc46a68b3d9b254b469f3869ec46738c0aabb0ccf0621444bb50bee306bdbe2fc
    HEAD_REF main
    PATCHES fix-cmake.patch
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
