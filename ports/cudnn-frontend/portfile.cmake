set(VCPKG_BUILD_TYPE release) # header only, INTERFACE library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA/cudnn-frontend
    REF "v${VERSION}"
    SHA512 a2ea1873aafa7a61a334a560d67d816056c151ad9b83789f412c61f15541da4652413d4e0d91930dadd00ef509f97c8ab473ed89da24ef6c2cde737e282303a6
    HEAD_REF main
    PATCHES
        fix-dependencies.patch
        version.patch
)
file(REMOVE_RECURSE "${SOURCE_PATH}/include/cudnn_frontend/thirdparty")

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
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/cudnn_frontend/AGENTS.md")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.txt"
        "${SOURCE_PATH}/LICENSE-MIT.txt"
        "${SOURCE_PATH}/LICENSING.md"
        "${SOURCE_PATH}/NOTICE"
        "${SOURCE_PATH}/THIRD_PARTY_LICENSES.txt"
)
