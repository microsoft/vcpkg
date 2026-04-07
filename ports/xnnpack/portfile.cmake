if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/XNNPACK
    REF 51a0103656eff6fc9bfd39a4597923c4b542c883 # 2024-12-03
    SHA512 ecb859935996416ce51b2b9ffd5a8c3cc5e933dfab96b7b68c8a52e05227ce3416ffa81e8a3fcef8349aa85147aa1c6a07138c7fc8e87a02ad577e1da9126827
    HEAD_REF master
    PATCHES
        fix-cmake.patch
)

vcpkg_find_acquire_program(PYTHON3)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DPython_EXECUTABLE=${PYTHON3}"
        -DXNNPACK_USE_SYSTEM_LIBS=ON
        -DXNNPACK_ENABLE_ASSEMBLY=ON
        -DXNNPACK_ENABLE_MEMOPT=ON
        -DXNNPACK_ENABLE_SPARSE=ON
        -DXNNPACK_BUILD_TESTS=OFF
        -DXNNPACK_BUILD_BENCHMARKS=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT})

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
