cmake_minimum_required(VERSION 3.20)

project(openfx VERSION 1.4.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(WIN32)
    add_compile_definitions(WINDOWS NOMINMAX WIN64)
    set(OS_VAR "windows")
    set(OFX_ARCH_NAME "Win64")
endif()

set(OFX_HEADERS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)

add_library(OpenFx INTERFACE)
target_include_directories(OpenFx
    INTERFACE
    $<BUILD_INTERFACE:${OFX_HEADERS_DIR}>
    $<INSTALL_INTERFACE:include/openfx>
)

add_subdirectory(Support)

install(
    TARGETS OpenFx OfxSupport
    EXPORT openfx-export
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(
    EXPORT openfx-export
    FILE unofficial-openfxConfig.cmake
    NAMESPACE unofficial::openfx::
    DESTINATION "share/unofficial-openfx"
)

file(GLOB OFX_HEADERS "${OFX_HEADERS_DIR}/*.h" "${OFX_SUPPORT_HEADERS_DIR}/*.h")
install(FILES ${OFX_HEADERS}
    DESTINATION include/openfx
)

include(CMakePackageConfigHelpers)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/unofficial-openfxConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
)
install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/unofficial-openfxConfigVersion.cmake"
    DESTINATION "share/unofficial-openfx"
)
