cmake_minimum_required(VERSION 3.4)

include(GNUInstallDirs)

project(FreeImage C CXX)

if(MSVC)
  add_definitions("-D_CRT_SECURE_NO_WARNINGS")
  set(CMAKE_CXX_FLAGS "/wd4828 ${CMAKE_CXX_FLAGS}")
endif()

find_package(ZLIB           REQUIRED)
find_package(PNG            REQUIRED)
find_package(JPEG           REQUIRED)
find_package(TIFF           REQUIRED)
find_package(OpenJPEG       REQUIRED)
find_package(WebP CONFIG    REQUIRED)
find_package(JXR            REQUIRED)
find_package(LibRaw         REQUIRED)
find_package(OpenEXR        REQUIRED)

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

add_library(FreeImage ${SRCS} ${PRIVATE_HEADERS} ${PUBLIC_HEADERS} ${CMAKE_CURRENT_SOURCE_DIR}/FreeImage.rc)

if(BUILD_SHARED_LIBS)
    target_compile_definitions(FreeImage PRIVATE -DFREEIMAGE_EXPORTS)
else()
    target_compile_definitions(FreeImage PRIVATE -DFREEIMAGE_LIB)
endif()

target_include_directories(FreeImage PRIVATE ${REAL_SOURCE_DIR}
                                             ${ZLIB_INCLUDE_DIRS}
                                             ${JPEG_INCLUDE_DIRS}
                                             ${TIFF_INCLUDE_DIRS}
                                             ${PNG_INCLUDE_DIRS}
                                             ${OPENJPEG_INCLUDE_DIRS}
                                             ${JXR_INCLUDE_DIRS}
                                             ${LibRaw_INCLUDE_DIRS}
                                             ${CMAKE_CURRENT_BINARY_DIR}
                                    PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)


target_link_libraries(FreeImage ${ZLIB_LIBRARIES}
                                ${JPEG_LIBRARIES}
                                ${TIFF_LIBRARIES}
                                ${PNG_LIBRARIES}
                                ${OPENJPEG_LIBRARIES}
                                WebP::webp WebP::webpdemux WebP::libwebpmux WebP::webpdecoder
                                ${JXR_LIBRARIES}
                                ${LibRaw_LIBRARIES}
                                OpenEXR::OpenEXR
                                Imath::Imath)

target_compile_definitions(FreeImage PRIVATE ${PNG_DEFINITIONS})

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

target_include_directories(FreeImagePlus PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/Wrapper/FreeImagePlus
                                                 ${CMAKE_CURRENT_BINARY_DIR}
                                                 ${REAL_SOURCE_DIR}
                                                 PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)

target_link_libraries(FreeImagePlus PUBLIC FreeImage)

list(APPEND PUBLIC_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/Wrapper/FreeImagePlus/FreeImagePlus.h)

install(TARGETS FreeImage FreeImagePlus
        EXPORT freeimage-targets
        COMPONENT runtime
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
        LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
        ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}")

install(EXPORT freeimage-targets NAMESPACE freeimage:: DESTINATION share/freeimage)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/freeimage-config.cmake"
"include(CMakeFindDependencyMacro)
find_dependency(ZLIB)
find_dependency(PNG)
find_dependency(JPEG)
find_dependency(TIFF)
find_dependency(OpenJPEG)
find_dependency(WebP CONFIG)
find_dependency(JXR)
find_dependency(LibRaw)
find_dependency(OpenEXR)
find_dependency(Imath)
include(\"\${CMAKE_CURRENT_LIST_DIR}/freeimage-targets.cmake\")
")

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/freeimage-config.cmake DESTINATION share/freeimage)
if(INSTALL_HEADERS)
    install(FILES ${PUBLIC_HEADERS} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
endif()
