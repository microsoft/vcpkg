cmake_minimum_required(VERSION 3.16)
project(rapidocr LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(OpenCV REQUIRED COMPONENTS core imgproc imgcodecs)
find_package(onnxruntime CONFIG REQUIRED)
find_package(polyclipping CONFIG REQUIRED)

set(RAPIDOCR_SOURCES
    src/AngleNet.cpp
    src/CrnnNet.cpp
    src/DbNet.cpp
    src/OcrLite.cpp
    src/OcrLiteCApi.cpp
    src/OcrResultUtils.cpp
    src/OcrUtils.cpp
)

add_library(rapidocr ${RAPIDOCR_SOURCES})
add_library(unofficial::rapidocr::rapidocr ALIAS rapidocr)

target_include_directories(rapidocr
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

# __CLIB__ gates the whole body of src/OcrLiteCApi.cpp, so it must stay defined
# for the C API to exist in the library at all. It also used to select
# dllexport/dllimport in OcrLiteCApi.h, but portfile.cmake strips that storage
# class, so consumers no longer need to define it to link.
target_compile_definitions(rapidocr
    PRIVATE
        UNICODE
        _UNICODE
        __CLIB__
)

if(MSVC)
    target_compile_options(rapidocr PRIVATE /utf-8 /W3)
    # Upstream uses some MSVC-specific aligned free paths.
    target_compile_definitions(rapidocr PRIVATE NOMINMAX)
endif()

# Prefer imported targets when present; fall back to OpenCV_LIBS (pulls jpeg/png/…).
if(TARGET opencv_core)
    set(_RAPIDOCR_OPENCV_LIBS opencv_core opencv_imgproc opencv_imgcodecs)
else()
    set(_RAPIDOCR_OPENCV_LIBS ${OpenCV_LIBS})
endif()

target_link_libraries(rapidocr
    PUBLIC
        onnxruntime::onnxruntime
        polyclipping::polyclipping
        ${_RAPIDOCR_OPENCV_LIBS}
)

set_target_properties(rapidocr PROPERTIES
    OUTPUT_NAME rapidocr
    EXPORT_NAME rapidocr
)

install(TARGETS rapidocr
    EXPORT unofficial-rapidocr-targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(DIRECTORY include/
    DESTINATION include/rapidocr
    FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.hpp"
        PATTERN "main.h" EXCLUDE
        PATTERN "getopt.h" EXCLUDE
        PATTERN "clipper.hpp" EXCLUDE
        PATTERN "OcrLiteJni*" EXCLUDE
)

include(CMakePackageConfigHelpers)
configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/unofficial-rapidocr-config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/unofficial-rapidocr-config.cmake"
    INSTALL_DESTINATION share/unofficial-rapidocr
)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/unofficial-rapidocr-config.cmake"
    DESTINATION share/unofficial-rapidocr)
install(EXPORT unofficial-rapidocr-targets
    NAMESPACE unofficial::rapidocr::
    DESTINATION share/unofficial-rapidocr
)
