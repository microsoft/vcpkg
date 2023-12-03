include("${CMAKE_CURRENT_LIST_DIR}/vcpkg_find_cuda.cmake")

set(ENV{CUDA_PATH} "${CURRENT_INSTALLED_DIR}")
vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/tools/cuda/bin")