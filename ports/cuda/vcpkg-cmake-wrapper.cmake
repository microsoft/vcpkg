set(CUDA_TOOLKIT_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}/../../tools/cuda" CACHE "FILEPATH" "" FORCE)
set(CUDAToolkit_ROOT "${CMAKE_CURRENT_LIST_DIR}/../../tools/cuda")
set(ENV{CUDA_PATH} "${CMAKE_CURRENT_LIST_DIR}/../../tools/cuda")

#Presearch cudart since it controls further lookup and does not take ENV CUDA_PATH as an input hint in older versions of CMake
find_library(CUDA_cudart_LIBRARY NAMES cudart HINTS "${CMAKE_CURRENT_LIST_DIR}/../../tools/cuda" ENV CUDA_PATH PATH_SUFFIXES lib64 lib/x64 lib)
_find_package(${ARGS})
