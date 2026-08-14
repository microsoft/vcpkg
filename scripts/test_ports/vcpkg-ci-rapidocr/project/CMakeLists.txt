cmake_minimum_required(VERSION 3.25.1)
project(vcpkg-ci-rapidocr LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
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

# CI opencv4[cuda] compiles CUDA objects into static opencv_core but does not
# INTERFACE-link the CUDA runtime. Consumers then fail with LNK2019 cudaMalloc
# (x64-windows-static Debug). Add the runtime when the toolkit is present.
find_package(CUDAToolkit QUIET)
if(TARGET CUDA::cudart)
    target_link_libraries(cmake_cxx PRIVATE CUDA::cudart)
    target_link_libraries(cmake_capi PRIVATE CUDA::cudart)
endif()

# C API header must compile with only the triplet include root (no opencv4).
find_path(RAPIDOCR_INCLUDE_DIR NAMES rapidocr/OcrLiteCApi.h REQUIRED)
try_compile(RAPIDOCR_CAPI_ROOT_OK
    "${CMAKE_CURRENT_BINARY_DIR}/capi-root-try"
    "${CMAKE_CURRENT_SOURCE_DIR}/direct_capi.cpp"
    CMAKE_FLAGS "-DINCLUDE_DIRECTORIES=${RAPIDOCR_INCLUDE_DIR}"
    OUTPUT_VARIABLE RAPIDOCR_CAPI_ROOT_OUT
)
if(NOT RAPIDOCR_CAPI_ROOT_OK)
    message(FATAL_ERROR "OcrLiteCApi.h did not compile from the include root:\n${RAPIDOCR_CAPI_ROOT_OUT}")
endif()
