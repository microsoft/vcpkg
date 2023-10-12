# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

cmake_minimum_required(VERSION 3.1)

project(OtlpProtoLib CXX)

include("${CMAKE_CURRENT_SOURCE_DIR}/tools.cmake")

find_package(Protobuf REQUIRED)
if(WITH_OTLP_GRPC)
    find_package(gRPC REQUIRED)
endif()

set(COMMON_PROTO "${CMAKE_CURRENT_SOURCE_DIR}/opentelemetry/proto/common/v1/common.proto")
set(RESOURCE_PROTO
    "${CMAKE_CURRENT_SOURCE_DIR}/opentelemetry/proto/resource/v1/resource.proto")
set(TRACE_PROTO "${CMAKE_CURRENT_SOURCE_DIR}/opentelemetry/proto/trace/v1/trace.proto")
set(LOGS_PROTO "${CMAKE_CURRENT_SOURCE_DIR}/opentelemetry/proto/logs/v1/logs.proto")
set(METRICS_PROTO "${CMAKE_CURRENT_SOURCE_DIR}/opentelemetry/proto/metrics/v1/metrics.proto")
set(TRACE_SERVICE_PROTO
    "${CMAKE_CURRENT_SOURCE_DIR}/opentelemetry/proto/collector/trace/v1/trace_service.proto")
set(LOGS_SERVICE_PROTO
    "${CMAKE_CURRENT_SOURCE_DIR}/opentelemetry/proto/collector/logs/v1/logs_service.proto")
set(METRICS_SERVICE_PROTO
    "${CMAKE_CURRENT_SOURCE_DIR}/opentelemetry/proto/collector/metrics/v1/metrics_service.proto"
)

set(GENERATED_PROTOBUF_PATH
    "${CMAKE_BINARY_DIR}/generated/third_party/opentelemetry-proto")

file(MAKE_DIRECTORY "${GENERATED_PROTOBUF_PATH}")

set(COMMON_PB_CPP_FILE
    "${GENERATED_PROTOBUF_PATH}/opentelemetry/proto/common/v1/common.pb.cc")
set(COMMON_PB_H_FILE
    "${GENERATED_PROTOBUF_PATH}/opentelemetry/proto/common/v1/common.pb.h")
set(RESOURCE_PB_CPP_FILE
    "${GENERATED_PROTOBUF_PATH}/opentelemetry/proto/resource/v1/resource.pb.cc")
set(RESOURCE_PB_H_FILE
    "${GENERATED_PROTOBUF_PATH}/opentelemetry/proto/resource/v1/resource.pb.h")
set(TRACE_PB_CPP_FILE
    "${GENERATED_PROTOBUF_PATH}/opentelemetry/proto/trace/v1/trace.pb.cc")
set(TRACE_PB_H_FILE
    "${GENERATED_PROTOBUF_PATH}/opentelemetry/proto/trace/v1/trace.pb.h")
set(LOGS_PB_CPP_FILE
    "${GENERATED_PROTOBUF_PATH}/opentelemetry/proto/logs/v1/logs.pb.cc")
set(LOGS_PB_H_FILE
    "${GENERATED_PROTOBUF_PATH}/opentelemetry/proto/logs/v1/logs.pb.h")
set(METRICS_PB_CPP_FILE
    "${GENERATED_PROTOBUF_PATH}/opentelemetry/proto/metrics/v1/metrics.pb.cc")
set(METRICS_PB_H_FILE
    "${GENERATED_PROTOBUF_PATH}/opentelemetry/proto/metrics/v1/metrics.pb.h")

set(TRACE_SERVICE_PB_CPP_FILE
    "${GENERATED_PROTOBUF_PATH}/opentelemetry/proto/collector/trace/v1/trace_service.pb.cc"
)
set(TRACE_SERVICE_PB_H_FILE
    "${GENERATED_PROTOBUF_PATH}/opentelemetry/proto/collector/trace/v1/trace_service.pb.h"
)
if(WITH_OTLP_GRPC)
    set(TRACE_SERVICE_GRPC_PB_CPP_FILE
        "${GENERATED_PROTOBUF_PATH}/opentelemetry/proto/collector/trace/v1/trace_service.grpc.pb.cc"
    )
    set(TRACE_SERVICE_GRPC_PB_H_FILE
        "${GENERATED_PROTOBUF_PATH}/opentelemetry/proto/collector/trace/v1/trace_service.grpc.pb.h"
    )
endif()
set(LOGS_SERVICE_PB_CPP_FILE
    "${GENERATED_PROTOBUF_PATH}/opentelemetry/proto/collector/logs/v1/logs_service.pb.cc"
)
set(LOGS_SERVICE_PB_H_FILE
    "${GENERATED_PROTOBUF_PATH}/opentelemetry/proto/collector/logs/v1/logs_service.pb.h"
)
if(WITH_OTLP_GRPC)
    set(LOGS_SERVICE_GRPC_PB_CPP_FILE
        "${GENERATED_PROTOBUF_PATH}/opentelemetry/proto/collector/logs/v1/logs_service.grpc.pb.cc"
    )
    set(LOGS_SERVICE_GRPC_PB_H_FILE
        "${GENERATED_PROTOBUF_PATH}/opentelemetry/proto/collector/logs/v1/logs_service.grpc.pb.h"
    )
endif()
set(METRICS_SERVICE_PB_CPP_FILE
    "${GENERATED_PROTOBUF_PATH}/opentelemetry/proto/collector/metrics/v1/metrics_service.pb.cc"
)
set(METRICS_SERVICE_PB_H_FILE
    "${GENERATED_PROTOBUF_PATH}/opentelemetry/proto/collector/metrics/v1/metrics_service.pb.h"
)
if(WITH_OTLP_GRPC)
    set(METRICS_SERVICE_GRPC_PB_CPP_FILE
        "${GENERATED_PROTOBUF_PATH}/opentelemetry/proto/collector/metrics/v1/metrics_service.grpc.pb.cc"
    )
    set(METRICS_SERVICE_GRPC_PB_H_FILE
        "${GENERATED_PROTOBUF_PATH}/opentelemetry/proto/collector/metrics/v1/metrics_service.grpc.pb.h"
    )
endif()

foreach(IMPORT_DIR ${PROTOBUF_IMPORT_DIRS})
    list(APPEND PROTOBUF_INCLUDE_FLAGS "-I${IMPORT_DIR}")
endforeach()

if(WITH_OTLP_GRPC)
    if(CMAKE_CROSSCOMPILING)
        find_program(gRPC_CPP_PLUGIN_EXECUTABLE grpc_cpp_plugin)
    else()
        if(TARGET gRPC::grpc_cpp_plugin)
            project_build_tools_get_imported_location(gRPC_CPP_PLUGIN_EXECUTABLE
                                                    gRPC::grpc_cpp_plugin)
        else()
            find_program(gRPC_CPP_PLUGIN_EXECUTABLE grpc_cpp_plugin)
        endif()
    endif()
  message(STATUS "gRPC_CPP_PLUGIN_EXECUTABLE=${gRPC_CPP_PLUGIN_EXECUTABLE}")
endif()

set(PROTOBUF_COMMON_FLAGS "--proto_path=${CMAKE_CURRENT_SOURCE_DIR}"
                          "--cpp_out=${GENERATED_PROTOBUF_PATH}")

# --experimental_allow_proto3_optional is available from 3.13 and be stable and
# enabled by default from 3.16
if(Protobuf_VERSION AND Protobuf_VERSION VERSION_LESS "3.16")
    list(APPEND PROTOBUF_COMMON_FLAGS "--experimental_allow_proto3_optional")
elseif(PROTOBUF_VERSION AND PROTOBUF_VERSION VERSION_LESS "3.16")
    list(APPEND PROTOBUF_COMMON_FLAGS "--experimental_allow_proto3_optional")
endif()

set(PROTOBUF_GENERATED_FILES
    ${COMMON_PB_H_FILE}
    ${COMMON_PB_CPP_FILE}
    ${RESOURCE_PB_H_FILE}
    ${RESOURCE_PB_CPP_FILE}
    ${TRACE_PB_H_FILE}
    ${TRACE_PB_CPP_FILE}
    ${LOGS_PB_H_FILE}
    ${LOGS_PB_CPP_FILE}
    ${METRICS_PB_H_FILE}
    ${METRICS_PB_CPP_FILE}
    ${TRACE_SERVICE_PB_H_FILE}
    ${TRACE_SERVICE_PB_CPP_FILE}
    ${LOGS_SERVICE_PB_H_FILE}
    ${LOGS_SERVICE_PB_CPP_FILE}
    ${METRICS_SERVICE_PB_H_FILE}
    ${METRICS_SERVICE_PB_CPP_FILE})

if(WITH_OTLP_GRPC)
    list(APPEND PROTOBUF_COMMON_FLAGS
         "--grpc_out=generate_mock_code=true:${GENERATED_PROTOBUF_PATH}"
         --plugin=protoc-gen-grpc="${gRPC_CPP_PLUGIN_EXECUTABLE}")
  
    list(
        APPEND
        PROTOBUF_GENERATED_FILES
        ${TRACE_SERVICE_GRPC_PB_H_FILE}
        ${TRACE_SERVICE_GRPC_PB_CPP_FILE}
        ${LOGS_SERVICE_GRPC_PB_H_FILE}
        ${LOGS_SERVICE_GRPC_PB_CPP_FILE}
        ${METRICS_SERVICE_GRPC_PB_H_FILE}
        ${METRICS_SERVICE_GRPC_PB_CPP_FILE})
endif()

set(PROTOBUF_RUN_PROTOC_COMMAND "\"${PROTOBUF_PROTOC_EXECUTABLE}\"")
foreach(
    PROTOBUF_RUN_PROTOC_ARG
    ${PROTOBUF_COMMON_FLAGS}
    ${PROTOBUF_INCLUDE_FLAGS}
    ${COMMON_PROTO}
    ${RESOURCE_PROTO}
    ${TRACE_PROTO}
    ${LOGS_PROTO}
    ${METRICS_PROTO}
    ${TRACE_SERVICE_PROTO}
    ${LOGS_SERVICE_PROTO}
    ${METRICS_SERVICE_PROTO})
    set(PROTOBUF_RUN_PROTOC_COMMAND
        "${PROTOBUF_RUN_PROTOC_COMMAND} \"${PROTOBUF_RUN_PROTOC_ARG}\"")
endforeach()

add_custom_command(
    OUTPUT ${PROTOBUF_GENERATED_FILES}
    COMMAND
        ${PROTOBUF_PROTOC_EXECUTABLE} ${PROTOBUF_COMMON_FLAGS}
        ${PROTOBUF_INCLUDE_FLAGS} ${COMMON_PROTO} ${RESOURCE_PROTO} ${TRACE_PROTO}
        ${LOGS_PROTO} ${METRICS_PROTO} ${TRACE_SERVICE_PROTO} ${LOGS_SERVICE_PROTO}
        ${METRICS_SERVICE_PROTO}
    COMMENT "[Run]: ${PROTOBUF_RUN_PROTOC_COMMAND}")

include_directories("${GENERATED_PROTOBUF_PATH}")

unset(OTELCPP_PROTO_TARGET_OPTIONS)
if(CMAKE_SYSTEM_NAME MATCHES "Windows|MinGW|WindowsStore")
    list(APPEND OTELCPP_PROTO_TARGET_OPTIONS STATIC)
elseif(NOT DEFINED BUILD_SHARED_LIBS OR BUILD_SHARED_LIBS)
    list(APPEND OTELCPP_PROTO_TARGET_OPTIONS SHARED)
else()
    list(APPEND OTELCPP_PROTO_TARGET_OPTIONS STATIC)
endif()

set(OPENTELEMETRY_PROTO_TARGETS opentelemetry_proto)
add_library(
    opentelemetry_proto
    ${OTELCPP_PROTO_TARGET_OPTIONS}
    ${COMMON_PB_CPP_FILE}
    ${RESOURCE_PB_CPP_FILE}
    ${TRACE_PB_CPP_FILE}
    ${LOGS_PB_CPP_FILE}
    ${METRICS_PB_CPP_FILE}
    ${TRACE_SERVICE_PB_CPP_FILE}
    ${LOGS_SERVICE_PB_CPP_FILE}
    ${METRICS_SERVICE_PB_CPP_FILE})

if(WITH_ABSEIL)
    find_package(absl REQUIRED)
    target_link_libraries(opentelemetry_proto PUBLIC absl::bad_variant_access)
endif()

if(WITH_OTLP_GRPC)
    add_library(
        opentelemetry_proto_grpc
        ${OTELCPP_PROTO_TARGET_OPTIONS} ${TRACE_SERVICE_GRPC_PB_CPP_FILE}
        ${LOGS_SERVICE_GRPC_PB_CPP_FILE} ${METRICS_SERVICE_GRPC_PB_CPP_FILE})

    list(APPEND OPENTELEMETRY_PROTO_TARGETS opentelemetry_proto_grpc)
    target_link_libraries(opentelemetry_proto_grpc
        PUBLIC opentelemetry_proto)

    get_target_property(grpc_lib_type gRPC::grpc++ TYPE)
    if (grpc_lib_type STREQUAL "SHARED_LIBRARY")
        target_link_libraries(opentelemetry_proto_grpc
        PUBLIC gRPC::grpc++)
    endif()
    set_target_properties(opentelemetry_proto_grpc PROPERTIES EXPORT_NAME
                                                            proto_grpc)
    patch_protobuf_targets(opentelemetry_proto_grpc)
    get_target_property(GRPC_INCLUDE_DIRECTORY gRPC::grpc++
                        INTERFACE_INCLUDE_DIRECTORIES)
    if(GRPC_INCLUDE_DIRECTORY)
        target_include_directories(
            opentelemetry_proto_grpc
            PUBLIC "$<BUILD_INTERFACE:${GRPC_INCLUDE_DIRECTORY}>")
    endif()
endif()

set_target_properties(opentelemetry_proto PROPERTIES EXPORT_NAME proto)
patch_protobuf_targets(opentelemetry_proto)

install(
    TARGETS ${OPENTELEMETRY_PROTO_TARGETS}
    EXPORT "${PROJECT_NAME}-target"
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})

install(
    DIRECTORY ${GENERATED_PROTOBUF_PATH}/opentelemetry
    DESTINATION include
    FILES_MATCHING
    PATTERN "*.h")

if(TARGET protobuf::libprotobuf)
    target_link_libraries(opentelemetry_proto PUBLIC protobuf::libprotobuf)
else() # cmake 3.8 or lower
    target_include_directories(opentelemetry_proto
                               PUBLIC ${Protobuf_INCLUDE_DIRS})
    target_link_libraries(opentelemetry_proto PUBLIC ${Protobuf_LIBRARIES})
endif()

if(WITH_OTLP_GRPC)
    if(WITH_ABSEIL)
        find_package(absl CONFIG)
        if(TARGET absl::synchronization)
            target_link_libraries(opentelemetry_proto_grpc
                                  PRIVATE absl::synchronization)
        endif()
    endif()
endif()

if(BUILD_SHARED_LIBS)
    foreach(proto_target ${OPENTELEMETRY_PROTO_TARGETS})
        set_property(TARGET ${proto_target} PROPERTY POSITION_INDEPENDENT_CODE ON)
    endforeach()
endif()