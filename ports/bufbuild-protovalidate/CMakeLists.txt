cmake_minimum_required(VERSION 3.23)

project(bufbuild-protovalidate CXX)

include(GNUInstallDirs)

find_package(Protobuf REQUIRED)

find_program(BUF_EXECUTABLE NAMES buf REQUIRED)
message(STATUS "Found Buf CLI: ${BUF_EXECUTABLE}")

file(CONFIGURE
    OUTPUT "buf.gen.yaml"
    CONTENT [[
version: v2
plugins:
  - protoc_builtin: cpp
    out: gen
    protoc_path: @Protobuf_PROTOC_EXECUTABLE@
]]
    @ONLY
)

unset(PB_CC_FILES)
unset(PB_H_FILES)

file(GLOB_RECURSE PROTO_FILES RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "*.proto")

foreach(file ${PROTO_FILES})
    get_filename_component(directory "${file}" DIRECTORY)
    get_filename_component(name_wle "${file}" NAME_WLE)
    list(APPEND PB_CC_FILES "${CMAKE_CURRENT_BINARY_DIR}/gen/${directory}/${name_wle}.pb.cc")
    list(APPEND PB_H_FILES "${CMAKE_CURRENT_BINARY_DIR}/gen/${directory}/${name_wle}.pb.h")
endforeach()

add_custom_command(
    OUTPUT ${PB_CC_FILES} ${PB_H_FILES}
    COMMAND ${BUF_EXECUTABLE} generate "${CMAKE_CURRENT_SOURCE_DIR}"
    DEPENDS ${PROTO_FILES} ${BUF_EXECUTABLE}
    COMMENT "Generating C++ code from Protobuf files"
    VERBATIM
)

add_library(${PROJECT_NAME} STATIC)
target_sources(${PROJECT_NAME}
    PRIVATE ${PB_CC_FILES}
    PUBLIC FILE_SET HEADERS BASE_DIRS "${CMAKE_CURRENT_BINARY_DIR}/gen" FILES ${PB_H_FILES}
)
target_link_libraries(${PROJECT_NAME} PUBLIC protobuf::libprotobuf)

install(TARGETS ${PROJECT_NAME}
    EXPORT unofficial-${PROJECT_NAME}-targets
    FILE_SET HEADERS
)
install(EXPORT unofficial-${PROJECT_NAME}-targets
    NAMESPACE unofficial::${PROJECT_NAME}::
    DESTINATION "${CMAKE_INSTALL_DATADIR}/unofficial-${PROJECT_NAME}"
)
file(CONFIGURE
    OUTPUT "unofficial-${PROJECT_NAME}-config.cmake"
    CONTENT [[
include(CMakeFindDependencyMacro)
find_dependency(Protobuf)
include("${CMAKE_CURRENT_LIST_DIR}/unofficial-@PROJECT_NAME@-targets.cmake")
]]
    @ONLY
)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/unofficial-${PROJECT_NAME}-config.cmake"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/unofficial-${PROJECT_NAME}"
)
