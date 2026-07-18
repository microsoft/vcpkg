cmake_minimum_required(VERSION 3.15)
project(cgltf LANGUAGES NONE)

add_library(cgltf INTERFACE)

target_include_directories(cgltf INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
)

install(TARGETS cgltf EXPORT cgltf-config)
install(FILES cgltf.h cgltf_write.h DESTINATION include)
install(EXPORT cgltf-config
    NAMESPACE cgltf::
    DESTINATION share/cgltf
)
