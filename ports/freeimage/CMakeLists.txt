cmake_minimum_required(VERSION 3.4)

include(GNUInstallDirs)

project(FreeImage
    VERSION 3.18.0
    DESCRIPTION "Support library for graphics image formats"
    HOMEPAGE_URL "https://sourceforge.net/projects/freeimage/"
    LANGUAGES C CXX
)

if(MSVC)
  add_definitions("-D_CRT_SECURE_NO_WARNINGS")
  set(CMAKE_CXX_FLAGS "/wd4828 ${CMAKE_CXX_FLAGS}")
endif()

if(BUILD_SHARED_LIBS)
  add_definitions("-DOPENEXR_DLL")
endif()

find_package(ZLIB     REQUIRED)
find_package(PNG      REQUIRED)
find_package(JPEG     REQUIRED)
find_package(TIFF     REQUIRED)
find_package(OpenJPEG CONFIG REQUIRED)
find_package(WebP     REQUIRED)
find_package(JXR      REQUIRED)
find_package(LibRaw   REQUIRED)
find_package(OpenEXR  REQUIRED)

option(BUILD_SHARED_LIBS "Build shared libraries" ON)
option(INSTALL_HEADERS "Install the development headers" ON)

set(REAL_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Source)

# Add a debug postfix
set(CMAKE_DEBUG_POSTFIX "d")

# List the public header files
set(PUBLIC_HEADERS ${REAL_SOURCE_DIR}/FreeImage.h)

# List the private header files
set(ROOT_PRIVATE_HEADERS ${REAL_SOURCE_DIR}/CacheFile.h
                         ${REAL_SOURCE_DIR}/FreeImageIO.h
                         ${REAL_SOURCE_DIR}/MapIntrospector.h
                         ${REAL_SOURCE_DIR}/Plugin.h
                         ${REAL_SOURCE_DIR}/Quantizers.h
                         ${REAL_SOURCE_DIR}/ToneMapping.h
                         ${REAL_SOURCE_DIR}/Utilities.h)

file(GLOB FREEIMAGE_PRIVATE_HEADERS ${REAL_SOURCE_DIR}/FreeImage/*.h)
file(GLOB FREEIMAGE_TOOLKIT_PRIVATE_HEADERS ${REAL_SOURCE_DIR}/FreeImageToolkit/*.h)
file(GLOB METADATA_PRIVATE_HEADERS ${REAL_SOURCE_DIR}/Metadata/*.h)

set(PRIVATE_HEADERS ${ROOT_PRIVATE_HEADERS}
                    ${FREEIMAGE_PRIVATE_HEADERS}
                    ${FREEIMAGE_TOOLKIT_PRIVATE_HEADERS}
                    ${METADATA_PRIVATE_HEADERS})

# List the source files
file(GLOB DEPRECATION_SRCS ${REAL_SOURCE_DIR}/DeprecationManager/*.cpp)
file(GLOB FREEIMAGE_TOOLKIT_SRCS ${REAL_SOURCE_DIR}/FreeImageToolkit/*.cpp)
file(GLOB FREEIMAGE_SRCS ${REAL_SOURCE_DIR}/FreeImage/*.cpp)
file(GLOB METADATA_SRCS ${REAL_SOURCE_DIR}/Metadata/*.cpp)

# The G3 plugin is disabled because it require the private copy of tiff
list(REMOVE_ITEM FREEIMAGE_SRCS ${REAL_SOURCE_DIR}/FreeImage/PluginG3.cpp)

# The JPEGTransform plugin is disable because it requires a private copy of jpeg
list(REMOVE_ITEM FREEIMAGE_TOOLKIT_SRCS ${REAL_SOURCE_DIR}/FreeImageToolkit/JPEGTransform.cpp)


set(SRCS ${DEPRECATION_SRCS}
         ${FREEIMAGE_SRCS}
         ${FREEIMAGE_TOOLKIT_SRCS}
         ${METADATA_SRCS}
)

# If FreeImage is used as a static library, FREEIMAGE_LIB
# needs to be defined (at the C preprocessor level) to correctly
# define (to nothing instead of _declspec(dllimport) ) the DLL_API macro.
# For this purpouse we include (depending on the BUILD_SHARED_LIBS )
# the appropriate FreeImageConfig.h .
if(BUILD_SHARED_LIBS)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/FreeImageConfig-dynamic.h ${CMAKE_CURRENT_BINARY_DIR}/FreeImageConfig.h)
else()
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/FreeImageConfig-static.h ${CMAKE_CURRENT_BINARY_DIR}/FreeImageConfig.h)
endif()
list(APPEND PUBLIC_HEADERS ${CMAKE_CURRENT_BINARY_DIR}/FreeImageConfig.h)

add_library(FreeImage ${SRCS} ${PRIVATE_HEADERS} ${PUBLIC_HEADERS})

if(BUILD_SHARED_LIBS)
    target_compile_definitions(FreeImage PRIVATE -DFREEIMAGE_EXPORTS)
else()
    target_compile_definitions(FreeImage PRIVATE -DFREEIMAGE_LIB)
endif()

target_include_directories(FreeImage
    INTERFACE
        $<INSTALL_INTERFACE:include>
    PRIVATE
        ${REAL_SOURCE_DIR}
        ${ZLIB_INCLUDE_DIRS}
        ${JPEG_INCLUDE_DIRS}
        ${TIFF_INCLUDE_DIRS}
        ${PNG_INCLUDE_DIRS}
        ${OPENJPEG_INCLUDE_DIRS}
        ${WEBP_INCLUDE_DIRS}
        ${JXR_INCLUDE_DIRS}
        ${LibRaw_INCLUDE_DIRS}
        ${OpenEXR_INCLUDE_DIRS}
        ${CMAKE_CURRENT_BINARY_DIR}
)

target_link_libraries(FreeImage
    PRIVATE
        ${ZLIB_LIBRARIES}
        ${JPEG_LIBRARIES}
        ${TIFF_LIBRARIES}
        ${PNG_LIBRARIES}
        ${OPENJPEG_LIBRARIES}
        ${WEBP_LIBRARIES}
        ${JXR_LIBRARIES}
        ${LibRaw_LIBRARIES}
        ${OpenEXR_LIBRARIES}
)

target_compile_definitions(FreeImage
    PRIVATE
        ${PNG_DEFINITIONS}
)

# FreeImagePlus
file(GLOB FREEIMAGEPLUS_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/Wrapper/FreeImagePlus/src/*.cpp)
add_library(FreeImagePlus
    ${FREEIMAGEPLUS_SOURCES}
    ${CMAKE_CURRENT_SOURCE_DIR}/Wrapper/FreeImagePlus/FreeImagePlus.h
    ${CMAKE_CURRENT_SOURCE_DIR}/Wrapper/FreeImagePlus/FreeImagePlus.rc)

if(BUILD_SHARED_LIBS)
    target_compile_definitions(FreeImagePlus PRIVATE -DFIP_EXPORTS)
else()
    target_compile_definitions(FreeImagePlus PRIVATE -DFREEIMAGE_LIB)
endif()

target_include_directories(FreeImagePlus
    INTERFACE
        $<INSTALL_INTERFACE:include>
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/Wrapper/FreeImagePlus
        ${CMAKE_CURRENT_BINARY_DIR}
        ${REAL_SOURCE_DIR}
)

target_link_libraries(FreeImagePlus
    PUBLIC
        FreeImage
)

list(APPEND PUBLIC_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/Wrapper/FreeImagePlus/FreeImagePlus.h)

install(TARGETS FreeImage
        EXPORT unofficial-FreeImageTargets
        COMPONENT runtime
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}" COMPONENT bin
        LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}" COMPONENT shlib
        ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}" COMPONENT lib)

install(TARGETS FreeImagePlus
        EXPORT unofficial-FreeImageTargets
        COMPONENT runtime-cpp
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}" COMPONENT bin
        LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}" COMPONENT shlib
        ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}" COMPONENT lib)

install(EXPORT unofficial-FreeImageTargets
    NAMESPACE unofficial-FreeImage::
    DESTINATION "${CMAKE_INSTALL_DATADIR}/unofficial-freeimage"
)

include(CMakePackageConfigHelpers)

file(WRITE "${CMAKE_BINARY_DIR}/unofficial-FreeImageConfig.cmake.in" [=[
    @PACKAGE_INIT@
    include("@PACKAGE_PATH_EXPORT_TARGETS@")
]=])

set(PATH_EXPORT_TARGETS "${CMAKE_INSTALL_DATADIR}/unofficial-freeimage/unofficial-FreeImageTargets.cmake")
configure_package_config_file(
    "${CMAKE_BINARY_DIR}/unofficial-FreeImageConfig.cmake.in"
    "${CMAKE_BINARY_DIR}/unofficial-FreeImageConfig.cmake"
    PATH_VARS
        PATH_EXPORT_TARGETS
    INSTALL_DESTINATION ${CMAKE_INSTALL_DATADIR}/unofficial-freeimage
)

write_basic_package_version_file("${CMAKE_BINARY_DIR}/unofficial-FreeImageConfigVersion.cmake"
  COMPATIBILITY AnyNewerVersion
)

install(
    FILES
        "${CMAKE_BINARY_DIR}/unofficial-FreeImageConfig.cmake"
        "${CMAKE_BINARY_DIR}/unofficial-FreeImageConfigVersion.cmake"
    DESTINATION
        "${CMAKE_INSTALL_DATADIR}/unofficial-freeimage"
)


if(INSTALL_HEADERS)
    install(FILES ${PUBLIC_HEADERS} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
endif()
