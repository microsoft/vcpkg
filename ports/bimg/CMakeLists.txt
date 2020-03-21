
cmake_minimum_required(VERSION 3.14 FATAL_ERROR)
project(bimg VERSION 2020.03.15.0 LANGUAGES C CXX)

include(GNUInstallDirs)

# dependencies
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads)
find_package(bx CONFIG REQUIRED)
find_package(Stb REQUIRED)
find_package(lodepng CONFIG REQUIRED)

find_package(OpenMP)
find_library(BIMG_SQUISH_LIBRARY_RELEASE squish)
find_library(BIMG_SQUISH_LIBRARY_DEBUG squishd)

# bimg base library target
add_library(bimg)
add_library(Bimg::bimg ALIAS bimg)

file(GLOB ASTC_DECODER_SOURCES "3rdparty/astc-codec/src/decoder/*.cc")

target_sources(bimg
    PRIVATE
        src/image.cpp
        src/image_gnf.cpp

        # astc codec sources
        ${ASTC_DECODER_SOURCES}
)

target_include_directories(bimg
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>

    PRIVATE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/astc-codec/>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/astc-codec/include>
)

target_link_libraries(bimg PUBLIC
    Bx::bx
)

# bimg_decode library target
add_library(bimg_decode)
add_library(Bimg::bimg_decode ALIAS bimg_decode)

target_sources(bimg_decode PRIVATE src/image_decode.cpp)

target_include_directories(bimg_decode
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>

    PRIVATE
        "${Stb_INCLUDE_DIR}"
)

target_link_libraries(bimg_decode PUBLIC
    Bx::bx
    Bimg::bimg

    lodepng
)

# bimg_encode library target
add_library(bimg_encode)
add_library(Bimg::bimg_encode ALIAS bimg_encode)

file(GLOB ASTC_SOURCES "3rdparty/astc/*.cpp")
file(GLOB IQA_SOURCES "3rdparty/iqa/source/*.c")
file(GLOB_RECURSE NVTT_SOURCES "3rdparty/nvtt/*.cpp")
file(GLOB PVRTC_SOURCES "3rdparty/pvrtc/*.cpp")

target_sources(bimg_encode
    PRIVATE
        src/image_encode.cpp
        src/image_cubemap_filter.cpp

        # astc
        ${ASTC_SOURCES}

        # edtaa3
        3rdparty/edtaa3/edtaa3func.cpp

        # etc1
        3rdparty/etc1/etc1.cpp

        # etc2
        3rdparty/etc2/ProcessRGB.cpp
        3rdparty/etc2/Tables.cpp

        # iqa
        ${IQA_SOURCES}

        # nvtt
        ${NVTT_SOURCES}

        # pvrtc
        ${PVRTC_SOURCES}
)

target_include_directories(bimg_encode
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>

    PRIVATE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/3rdparty>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/nvtt>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/iqa/include>
        "${Stb_INCLUDE_DIR}"
)

target_link_libraries(bimg_encode PUBLIC
    Bx::bx
    Bimg::bimg

    optimized "${BIMG_SQUISH_LIBRARY_RELEASE}"
    debug "${BIMG_SQUISH_LIBRARY_DEBUG}"
)
if (OpenMP_CXX_FOUND)
    target_link_libraries(bimg_encode PUBLIC OpenMP::OpenMP_CXX)
endif()

# texturec executable
add_executable(texturec)
add_executable(Bimg::texturec ALIAS texturec)

target_sources(texturec PRIVATE tools/texturec/texturec.cpp)

target_link_libraries(texturec PRIVATE
    Bx::bx
    Bimg::bimg
    Bimg::bimg_decode
    Bimg::bimg_encode
)

# installation logic
if (OpenMP_CXX_FOUND)
    set(BIMG_DEPENDS_OPENMP "find_dependency(OpenMP)")
endif()
configure_file(bimg-config.cmake.in bimg-config.cmake @ONLY)
install(FILES "${CMAKE_BINARY_DIR}/bimg-config.cmake" DESTINATION "${CMAKE_INSTALL_DATADIR}/bimg/")

if (BIMG_INSTALL_TOOLING)
    install(TARGETS texturec EXPORT tool-targets)

    install(EXPORT tool-targets NAMESPACE Bimg:: DESTINATION "${CMAKE_INSTALL_DATADIR}/bimg/")
endif()

install(TARGETS bimg bimg_decode bimg_encode EXPORT bimg-targets)
if (NOT BIMG_DISABLE_HEADER_INSTALL)
    install(DIRECTORY include/ TYPE INCLUDE)
endif()

install(EXPORT bimg-targets NAMESPACE Bimg:: DESTINATION "${CMAKE_INSTALL_DATADIR}/bimg/")
