vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO InteractiveComputerGraphics/TriangleMeshDistance
    REF 2cb643de1436e1ba8e2be49b07ec5491ac604457 # 2024-08-17
    SHA512 92a9e7c6e09c9184a3762ae7bb89ffae1ebe0ceead8fe5853cb809ec19c516ce4b3c2fcb3ecc5c2927e3578ebd548b571085527209ea0d58934440f932b554b0
    PATCHES
        cmake-export.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
   
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
