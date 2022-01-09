cmake_minimum_required(VERSION 3.1)
project(spirv-reflect)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set(CMAKE_CXX_STANDARD 14)

# set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin")

include(GNUInstallDirs)

add_library(spirv-reflect ${CMAKE_CURRENT_SOURCE_DIR}/spirv_reflect.h
                          ${CMAKE_CURRENT_SOURCE_DIR}/spirv_reflect.c)
target_compile_options(spirv-reflect PRIVATE
        $<$<CXX_COMPILER_ID:MSVC>:/W4 /WX>
        $<$<CXX_COMPILER_ID:GNU>:-Wall -Werror>
        $<$<CXX_COMPILER_ID:Clang>:-Wall -Werror>
        $<$<CXX_COMPILER_ID:AppleClang>:-Wall -Werror>)
if (SPIRV_REFLECT_ENABLE_ASSERTS)
    target_compile_definitions(spirv-reflect PRIVATE SPIRV_REFLECT_ENABLE_ASSERTS)
endif()
set_target_properties(spirv-reflect PROPERTIES CXX_STANDARD 11)
target_include_directories(spirv-reflect PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
if(WIN32)
    target_compile_definitions(spirv-reflect PRIVATE _CRT_SECURE_NO_WARNINGS)
endif()

# add_library(spirv-reflect INTERFACE)
target_include_directories(spirv-reflect INTERFACE $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)

install(
    TARGETS spirv-reflect EXPORT spirv-reflect-config
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}/
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}/
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/
)

install(
    EXPORT spirv-reflect-config
    NAMESPACE spirv-reflect::
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/spirv-reflect
)

message(DEBUG "INSTAL INCLUDE DIR: ${CMAKE_INSTALL_INCLUDEDIR}")

install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/spirv_reflect.h" DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/include" DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
