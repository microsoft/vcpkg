cmake_minimum_required(VERSION 3.14)
project(rewolf-wow64ext VERSION 1.0.0.9 LANGUAGES CXX)

include(CMakePackageConfigHelpers)

set(CMAKE_MSVC_RUNTIME_LIBRARY  "MultiThreaded$<$<CONFIG:Debug>:Debug>")

add_library(wow64ext SHARED
    src/wow64ext.cpp
    src/wow64ext.rc
    src/wow64ext.h
    src/internal.h
    src/CMemPtr.h
    src/resource.h
)

target_compile_features(wow64ext PRIVATE cxx_std_11)

target_compile_definitions(wow64ext PRIVATE WOW64EXT_EXPORTS)

target_compile_options(wow64ext PRIVATE
    /GR-
    /EHs-c-
    /GS-
    /d2FH4-
)

target_link_options(wow64ext PRIVATE
    /SUBSYSTEM:WINDOWS
    /ENTRY:DllMain
    /d2:-FH4-
)

target_link_libraries(wow64ext PRIVATE
    msvcrt
    kernel32
)

install(
    TARGETS wow64ext
    RUNTIME DESTINATION "bin"
    LIBRARY DESTINATION "lib"
    ARCHIVE DESTINATION "lib"
)

install(
    FILES "src/wow64ext.h"
    DESTINATION "include"
)

install(
    EXPORT wow64extTargets
    FILE wow64extTargets.cmake
    NAMESPACE wow64ext::
    DESTINATION "lib/cmake/wow64ext"
)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/wow64extConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/wow64extConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/wow64extConfig.cmake"
    INSTALL_DESTINATION "lib/cmake/wow64ext"
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/wow64extConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/wow64extConfigVersion.cmake"
    DESTINATION "lib/cmake/wow64ext"
)
