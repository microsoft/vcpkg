
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/XNNPACK
    REF a5e242c633af4e577fa206411082f1aba276602d
    SHA512 6b864018ae6689811a9a198fbd995330ab168b284c78907b170bdedd0e9dc2f99d1ff1b4fdd100a01e604ff83c6481d7845a533e37d0893288f41c896e91cace
    # PATCHES
    #     use-packages.patch # invoke find_package in CMakeLists.txt
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DXNNPACK_LIBRARY_TYPE=default
        -DXNNPACK_USE_SYSTEM_LIBS=OFF
        -DXNNPACK_ENABLE_ASSEMBLY=ON
        -DXNNPACK_ENABLE_MEMOPT=ON
        -DXNNPACK_ENABLE_SPARSE=ON
        -DXNNPACK_BUILD_TESTS=OFF
        -DXNNPACK_BUILD_BENCHMARKS=OFF
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/debug/bin
)
