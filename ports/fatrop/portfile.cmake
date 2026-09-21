vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO meco-group/fatrop
    REF "v${VERSION}"
    SHA512 deba948cabd86b0ba5252beeadb97b2892e4a3a72e031c30b1c54548313a381df6b8ef73c202c56d912d8b6256a18462c35155201c755eef641403e70691eac1
    HEAD_REF main
    PATCHES
        honor-build-shared-libs.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SHARED_LIBS=${BUILD_SHARED}
        -DWITH_BUILD_BLASFEO=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_WITH_C_INTERFACE=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/fatrop)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt" "${SOURCE_PATH}/LICENSE-EPL-2.0.txt")
