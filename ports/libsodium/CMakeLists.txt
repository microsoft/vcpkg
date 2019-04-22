cmake_minimum_required(VERSION 3.11)
project(sodium C)

if(BUILD_SHARED_LIBS)
    add_definitions(-DSODIUM_DLL_EXPORT "-DSODIUM_EXPORT=__declspec(dllexport)")
else()
    add_definitions(-DSODIUM_STATIC "-DSODIUM_EXPORT=")
endif()

set(SOURCES)

file(STRINGS libsodium.vcxproj _lines)
foreach(_line IN LISTS _lines)
    if(_line MATCHES "ClCompile Include=\"(.+\\.c)\"")
        string(REPLACE "\\" "/" SOURCE "${CMAKE_MATCH_1}")
        list(APPEND SOURCES "${SOURCE}")
    endif()
endforeach()

add_library(sodium ${SOURCES})
set_target_properties(sodium PROPERTIES PREFIX "lib" IMPORT_PREFIX "lib")
target_include_directories(sodium PRIVATE src/libsodium/include/sodium builds/msvc PUBLIC $<INSTALL_INTERFACE:include>)

install(TARGETS sodium EXPORT sodium)

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/Findsodium.cmake
"find_package(sodium CONFIG REQUIRED)
")

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/sodium-config.cmake
"include(\${CMAKE_CURRENT_LIST_DIR}/sodium-targets.cmake)
set(sodium_INCLUDE_DIR \"\${CMAKE_CURRENT_LIST_DIR}/../../include\")
set(sodium_LIBRARY_DEBUG sodium)
set(sodium_LIBRARY_RELEASE sodium)
")

install(
    FILES
        ${CMAKE_CURRENT_BINARY_DIR}/Findsodium.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/sodium-config.cmake
    DESTINATION share/sodium
)

install(
    EXPORT sodium
    DESTINATION share/sodium
    FILE sodium-targets.cmake
)
