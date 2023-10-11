cmake_minimum_required(VERSION 3.5)

project(OtlpProtoLib CXX)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/Modules/")

find_package(abseil REQUIRED)
find_package(Protobuf REQUIRED)
find_package(gRPC REQUIRED)

find_program(PROTOBUF_PROTOC_EXECUTABLE NAMES protoc)
find_program(GRPC_CPP_PLUGIN NAMES grpc_cpp_plugin)

set(OTLP_COMMON_PROTO "${CMAKE_CURRENT_SOURCE_DIR}/opentelemetry/proto/common/v1/common.proto")
set(OTLP_RESOURCE_PROTO "${CMAKE_CURRENT_SOURCE_DIR}/opentelemetry/proto/resource/v1/resource.proto")
set(OTLP_METRICS_PROTO "${CMAKE_CURRENT_SOURCE_DIR}/opentelemetry/proto/metrics/v1/metrics.proto")
set(OTLP_METRICS_SERVICE_PROTO "${CMAKE_CURRENT_SOURCE_DIR}/opentelemetry/proto/collector/metrics/v1/metrics_service.proto")

set(SOURCES
    "${OTLP_PROTO_OUT_DIR}/opentelemetry/proto/collector/metrics/v1/metrics_service.grpc.pb.cc"
    "${OTLP_PROTO_OUT_DIR}/opentelemetry/proto/collector/metrics/v1/metrics_service.pb.cc"
    "${OTLP_PROTO_OUT_DIR}/opentelemetry/proto/common/v1/common.grpc.pb.cc"
    "${OTLP_PROTO_OUT_DIR}/opentelemetry/proto/common/v1/common.pb.cc"
    "${OTLP_PROTO_OUT_DIR}/opentelemetry/proto/resource/v1/resource.grpc.pb.cc"
    "${OTLP_PROTO_OUT_DIR}/opentelemetry/proto/resource/v1/resource.pb.cc"
    "${OTLP_PROTO_OUT_DIR}/opentelemetry/proto/metrics/v1/metrics.grpc.pb.cc"
    "${OTLP_PROTO_OUT_DIR}/opentelemetry/proto/metrics/v1/metrics.pb.cc"
)

if(NOT EXISTS ${OTLP_PROTO_OUT_DIR})
    message(STATUS "Creating proto out folder: ${OTLP_PROTO_OUT_DIR}")
    file(MAKE_DIRECTORY ${OTLP_PROTO_OUT_DIR})
else()
    message(STATUS "Proto out folder is found: ${OTLP_PROTO_OUT_DIR}")
endif()

add_custom_command(
    OUTPUT ${SOURCES} #_fake.h
    COMMAND ${PROTOBUF_PROTOC_EXECUTABLE} --version
    COMMAND ${PROTOBUF_PROTOC_EXECUTABLE}
    ARGS
        --grpc_out "${OTLP_PROTO_OUT_DIR}"
        --cpp_out "${OTLP_PROTO_OUT_DIR}"
        -I "${OTLP_PROTO_BUILD_ROOT}"
        --plugin=protoc-gen-grpc="${GRPC_CPP_PLUGIN}"
        "${OTLP_COMMON_PROTO}" "${OTLP_METRICS_PROTO}" "${OTLP_RESOURCE_PROTO}" "${OTLP_METRICS_SERVICE_PROTO}"
    DEPENDS "${OTLP_COMMON_PROTO}" "${OTLP_METRICS_PROTO}" "${OTLP_RESOURCE_PROTO}" "${OTLP_METRICS_SERVICE_PROTO}"
    COMMENT "Compiling open-telemetry proto files"
)

add_library(${PROJECT_NAME} ${SOURCES})

target_link_libraries(${PROJECT_NAME}
    PRIVATE
    protobuf::libprotobuf
    gRPC::grpc++
    absl::synchronization
)
