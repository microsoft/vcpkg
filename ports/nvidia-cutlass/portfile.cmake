vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA/cutlass
    REF "v${VERSION}"
    SHA512 c950ab718e67ffc972911b81890eae767a27d32dfc13f72b91e21e7c6b98eadfb3a5eebb9683091e61aed61709481451cfcd95d660e723686bf79a155e9f0b17
    HEAD_REF main
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON_PATH "${PYTHON3}" PATH)
vcpkg_add_to_path(PREPEND "${PYTHON_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_SUPPRESS_REGENERATION=ON # for some reason it keeps regenerating in Windows
        "-DCUTLASS_REVISION:STRING=v${VERSION}"
        -DCUTLASS_NATIVE_CUDA=OFF
        -DCUTLASS_ENABLE_HEADERS_ONLY=ON
        -DCUTLASS_ENABLE_TOOLS=OFF
        -DCUTLASS_ENABLE_LIBRARY=OFF
        -DCUTLASS_ENABLE_PROFILER=OFF
        -DCUTLASS_ENABLE_PERFORMANCE=OFF
        -DCUTLASS_ENABLE_TESTS=OFF
        -DCUTLASS_ENABLE_GTEST_UNIT_TESTS=OFF
        -DCUTLASS_ENABLE_CUBLAS=ON
        -DCUTLASS_ENABLE_CUDNN=ON
        "-DPython3_EXECUTABLE:FILEPATH=${PYTHON3}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/NvidiaCutlass" PACKAGE_NAME "NvidiaCutlass")

# note CUTLASS_ENABLE_LIBRARY=OFF
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/NvidiaCutlass/NvidiaCutlassConfig.cmake"
    "add_library" "# add_library" # comment out the command
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/test"
    "${CURRENT_PACKAGES_DIR}/lib"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
