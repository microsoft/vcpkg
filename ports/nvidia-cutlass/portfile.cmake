vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA/cutlass
    REF "v${VERSION}"
    SHA512 eebeda9c72671521377bc7baef2eef4fc429de46bc43e22f31c6a605ebda501dc0223e53ff1ec6590d9c3b2855462b04ddc07a5f2871c6be64d54bbe9fd18061
    HEAD_REF main
    PATCHES
        fix-cudnn-path.patch
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



file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/test"
    "${CURRENT_PACKAGES_DIR}/lib"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
