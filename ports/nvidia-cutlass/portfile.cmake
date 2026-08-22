vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA/cutlass
    REF "v${VERSION}"
    SHA512 0725370991c997c1285e205f3ead58e2bb234974e50073a59698cb4f960aeffc2f70c15765c746826bd30d8a88ae5a2b26011878120196ba40dc65f739ab5b8f
    HEAD_REF main
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON_PATH "${PYTHON3}" PATH)
vcpkg_add_to_path(PREPEND "${PYTHON_PATH}")

vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT cuda_toolkit_root)
list(APPEND FEATURE_OPTIONS
    "-DCMAKE_CUDA_COMPILER=${NVCC}"
    "-DCUDAToolkit_ROOT=${cuda_toolkit_root}"
)

list(APPEND CMAKE_MODULE_PATH "${CURRENT_INSTALLED_DIR}/share/cudnn")
find_package(CUDNN REQUIRED)
get_filename_component(CUDNN_LIBRARY_DIR "${CUDNN_LIBRARIES}" DIRECTORY)
set(ENV{CUDNN_PATH} "${CUDNN_LIBRARY_DIR};${CUDNN_INCLUDE_DIRS}")


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_SUPPRESS_REGENERATION=ON # for some reason it keeps regenerating in Windows
        "-DCUTLASS_REVISION:STRING=v${VERSION}"
        -DCUTLASS_NATIVE_CUDA=OFF
        -DCUTLASS_ENABLE_HEADERS_ONLY=ON
        -DCUTLASS_ENABLE_TOOLS=ON
        -DCUTLASS_ENABLE_LIBRARY=OFF
        -DCUTLASS_ENABLE_PROFILER=OFF
        -DCUTLASS_ENABLE_PERFORMANCE=OFF
        -DCUTLASS_ENABLE_TESTS=OFF
        -DCUTLASS_ENABLE_GTEST_UNIT_TESTS=OFF
        -DCUTLASS_ENABLE_CUBLAS=ON
        -DCUTLASS_ENABLE_CUDNN=ON
        "-DPython3_EXECUTABLE:FILEPATH=${PYTHON3}"
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        CUTLASS_NATIVE_CUDA
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/NvidiaCutlass" PACKAGE_NAME "NvidiaCutlass")

vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/include/cutlass/version.h"
    "@CUTLASS_VERSION@"
    "${VERSION}"
)
vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/include/cutlass/version.h"
    "@CUTLASS_REVISION@"
    "v${VERSION}"
)
vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/share/NvidiaCutlass/NvidiaCutlassTargets.cmake"
    "INTERFACE_COMPILE_DEFINITIONS \""
    "INTERFACE_COMPILE_DEFINITIONS \"CUTLASS_VERSIONS_GENERATED;"
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/test"
    "${CURRENT_PACKAGES_DIR}/lib"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
