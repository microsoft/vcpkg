cmake_minimum_required(VERSION 3.25.1)
project(vcpkg-ci-rapidocr LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC OFF)
set(CMAKE_AUTORCC OFF)
set(CMAKE_AUTOUIC OFF)

find_package(unofficial-rapidocr CONFIG REQUIRED)
# CI opencv4[qt] can turn AUTOMOC on while resolving find_dependency(OpenCV).
set(CMAKE_AUTOMOC OFF)
set(CMAKE_AUTORCC OFF)
set(CMAKE_AUTOUIC OFF)

add_executable(cmake_cxx cmake_cxx.cpp)
target_link_libraries(cmake_cxx PRIVATE unofficial::rapidocr::rapidocr)

add_executable(cmake_capi cmake_capi.cpp)
target_link_libraries(cmake_capi PRIVATE unofficial::rapidocr::rapidocr)

add_executable(cmake_c cmake_c.c)
target_link_libraries(cmake_c PRIVATE unofficial::rapidocr::rapidocr)

# CI opencv4[cuda] compiles CUDA objects into static opencv_core but does not
# INTERFACE-link the CUDA runtime. Consumers then fail with LNK2019 cudaMalloc
# (x64-windows-static Debug). Only probe CUDAToolkit on x64 Windows: the ARM
# Windows agents have a host x64 CUDA install, and CMake 4.4's FindCUDAToolkit
# then errors with unknown command _CUDAToolkit_find_and_add_import_lib.
if(WIN32 AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    find_package(CUDAToolkit QUIET)
    if(TARGET CUDA::cudart)
        foreach(tgt IN ITEMS cmake_cxx cmake_capi cmake_c)
            target_link_libraries(${tgt} PRIVATE CUDA::cudart)
        endforeach()
    endif()
endif()

# C API header must compile as C from the triplet include root (no opencv4).
find_path(RAPIDOCR_INCLUDE_DIR NAMES rapidocr/OcrLiteCApi.h REQUIRED)
try_compile(RAPIDOCR_CAPI_ROOT_OK
    "${CMAKE_CURRENT_BINARY_DIR}/capi-root-try"
    "${CMAKE_CURRENT_SOURCE_DIR}/direct_capi.c"
    CMAKE_FLAGS "-DINCLUDE_DIRECTORIES=${RAPIDOCR_INCLUDE_DIR}"
    OUTPUT_VARIABLE RAPIDOCR_CAPI_ROOT_OUT
)
if(NOT RAPIDOCR_CAPI_ROOT_OK)
    message(FATAL_ERROR "OcrLiteCApi.h did not compile as C from the include root:\n${RAPIDOCR_CAPI_ROOT_OUT}")
endif()
