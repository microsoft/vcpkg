vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/tvm-ffi
    REF "v${VERSION}"
    SHA512 671c1c9a1872428c80fc7b5065ecf0557105dd5b5384046dea98cfd89974db49b4afe7381265d6ea1cc6df4ee645769c8f5a161737be930c75ba601e53298ca1
    HEAD_REF main
    PATCHES
        cmake-install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTVM_FFI_USE_LIBBACKTRACE=OFF
        -DTVM_FFI_BUILD_TESTS=OFF
        -DTVM_FFI_BUILD_PYTHON_MODULE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME tvm_ffi CONFIG_PATH lib/cmake/tvm_ffi)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/NOTICE")
