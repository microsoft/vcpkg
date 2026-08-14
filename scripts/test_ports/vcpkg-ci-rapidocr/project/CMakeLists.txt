cmake_minimum_required(VERSION 3.25.1)
project(vcpkg-ci-rapidocr LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(unofficial-rapidocr CONFIG REQUIRED)

add_executable(cmake_cxx cmake_cxx.cpp)
target_link_libraries(cmake_cxx PRIVATE unofficial::rapidocr::rapidocr)

add_executable(cmake_capi cmake_capi.cpp)
target_link_libraries(cmake_capi PRIVATE unofficial::rapidocr::rapidocr)

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
