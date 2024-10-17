vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/dawn
    REF fda42b9b030a9da4a3f3b3dc994bdba9eeb36b38
    SHA512 579e49753b22300390d929ded3fed7d8efd5babb97be8bd71c5789da7e797423e3718d23c9a47799c19bae6b4911b43925ba3c8bfd649c9bc45c10bb3515a2e1
    HEAD_REF master
    PATCHES
        dawn-find_package.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SPIRV-Tools_SOURCE_PATH
    REPO KhronosGroup/SPIRV-Tools
    REF "vulkan-sdk-1.3.280.0"
    SHA512 3ccab3118e0a1d6f20d031cd1f90f2546b618370b90aacc468fc598d523463452f65ed2c89c1de4e2bb8933b9757eb8123363483bcd853e92d41c95ea419e79f
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DDAWN_BUILD_SAMPLES=OFF
        -DDAWN_ENABLE_INSTALL=ON
        -DDAWN_JINJA2_DIR=OFF
        -DDAWN_USE_GLFW=OFF # TODO: I somehow get linker errors when enabling this
        -DTINT_BUILD_CMD_TOOLS=OFF
        -DTINT_BUILD_TESTS=OFF
        -DTINT_ENABLE_INSTALL=ON
        "-DDAWN_SPIRV_TOOLS_DIR=${SPIRV-Tools_SOURCE_PATH}"
        -DSPIRV_TOOLS_BUILD_STATIC=ON
)

vcpkg_cmake_install()
#vcpkg_cmake_config_fixup(PACKAGE_NAME absl CONFIG_PATH lib/cmake/absl)
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")