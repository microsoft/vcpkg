vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA/cudnn-frontend
    REF "v${VERSION}"
    SHA512 95dbf57594eda08905f176f6f18be297cfbac571460829c55959f15e87f92e9019812ff367bf857dc26d6961d9c6393e667b09e855732e3ab7645e93f325efa1
    HEAD_REF main
)
file(REMOVE_RECURSE "${SOURCE_PATH}/include/cudnn_frontend/thirdparty")

set(VCPKG_BUILD_TYPE release) # header only, INTERFACE library

vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT cuda_toolkit_root) 

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_CUDA_COMPILER:FILEPATH=${NVCC}" 
        "-DCUDAToolkit_ROOT=${cuda_toolkit_root}" 
        -DCUDNN_FRONTEND_BUILD_PYTHON_BINDINGS=OFF
        -DCUDNN_FRONTEND_BUILD_TESTS=OFF
        -DCUDNN_FRONTEND_BUILD_SAMPLES=OFF
        -DCUDNN_FRONTEND_SKIP_JSON_LIB=OFF # no macro definition
    MAYBE_UNUSED_VARIABLES
        CUDNN_FRONTEND_FETCH_PYBINDS_IN_CMAKE
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cudnn_frontend PACKAGE_NAME cudnn_frontend)

# make the installed files to see nlohmann/json.hpp from vcpkg
vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/include/cudnn_frontend_utils.h"
    "\"cudnn_frontend/thirdparty/nlohmann/json.hpp\"" "<nlohmann/json.hpp>"
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
