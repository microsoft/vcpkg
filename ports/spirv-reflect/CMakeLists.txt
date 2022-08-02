cmake_minimum_required(VERSION 3.1)
project(spirv-reflect)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

add_library(spirv-reflect ${CMAKE_CURRENT_SOURCE_DIR}/spirv_reflect.h
                          ${CMAKE_CURRENT_SOURCE_DIR}/spirv_reflect.c)
if (SPIRV_REFLECT_ENABLE_ASSERTS)
    target_compile_definitions(spirv-reflect PRIVATE SPIRV_REFLECT_ENABLE_ASSERTS)
endif()
set_target_properties(spirv-reflect PROPERTIES CXX_STANDARD 11)
target_include_directories(spirv-reflect PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
if(WIN32)
    target_compile_definitions(spirv-reflect PRIVATE _CRT_SECURE_NO_WARNINGS)
endif()

target_include_directories(spirv-reflect INTERFACE $<INSTALL_INTERFACE:include>)

install(
    TARGETS spirv-reflect EXPORT unofficial-spirv-reflect-config
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

install(
    EXPORT unofficial-spirv-reflect-config
    NAMESPACE unofficial::spirv-reflect::
    DESTINATION share/unofficial-spirv-reflect
)

install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/spirv_reflect.h" DESTINATION include)
install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/include" DESTINATION include)
