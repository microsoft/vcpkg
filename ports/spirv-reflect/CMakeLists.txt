cmake_minimum_required(VERSION 3.1)
project(spirv-reflect)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

find_package(SPIRV-Headers REQUIRED)

add_library(spirv-reflect ${CMAKE_CURRENT_SOURCE_DIR}/spirv_reflect.h
                          ${CMAKE_CURRENT_SOURCE_DIR}/spirv_reflect.c)
if (SPIRV_REFLECT_ENABLE_ASSERTS)
    target_compile_definitions(spirv-reflect PRIVATE SPIRV_REFLECT_ENABLE_ASSERTS)
endif()
set_target_properties(spirv-reflect PROPERTIES CXX_STANDARD 11)
if(WIN32)
    target_compile_definitions(spirv-reflect PRIVATE _CRT_SECURE_NO_WARNINGS)
endif()
target_link_libraries(spirv-reflect PUBLIC SPIRV-Headers::SPIRV-Headers)
target_compile_definitions(spirv-reflect PUBLIC SPIRV_REFLECT_USE_SYSTEM_SPIRV_H)

target_include_directories(spirv-reflect INTERFACE $<INSTALL_INTERFACE:include>)

set(config_file ${CMAKE_CURRENT_BINARY_DIR}/unofficial-spirv-reflect-config.cmake)
set(targets unofficial-spirv-reflect-targets)

file(WRITE ${config_file}
"include(CMakeFindDependencyMacro)
find_dependency(SPIRV-Headers)
include(\${CMAKE_CURRENT_LIST_DIR}/${targets}.cmake)")

install(FILES ${config_file} DESTINATION share/unofficial-spirv-reflect)

install(
    TARGETS spirv-reflect EXPORT ${targets}
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

install(
    EXPORT ${targets}
    NAMESPACE unofficial::spirv-reflect::
    DESTINATION share/unofficial-spirv-reflect
)

install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/spirv_reflect.h" DESTINATION include)
