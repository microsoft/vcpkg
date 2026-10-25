cmake_minimum_required(VERSION 3.20)
project(coremltools-mlmodel LANGUAGES CXX)

include(GNUInstallDirs)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(NOT COREMLTOOLS_SOURCE_DIR)
	message(FATAL_ERROR "COREMLTOOLS_SOURCE_DIR must point to the coremltools sources.")
endif()

find_package(Protobuf CONFIG REQUIRED)
find_package(nlohmann_json CONFIG REQUIRED)
find_package(unofficial-fp16 CONFIG REQUIRED)
if(CMAKE_SYSTEM_NAME STREQUAL "Linux" OR CMAKE_SYSTEM_NAME STREQUAL "Android")
	find_package(unofficial-libuuid CONFIG REQUIRED)
endif()

# CoreML protobuf specification
set(PROTO_ROOT "${COREMLTOOLS_SOURCE_DIR}/mlmodel/format")
file(GLOB COREML_PROTOS "${PROTO_ROOT}/*.proto")
set(PROTO_OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/coreml_proto")
file(MAKE_DIRECTORY "${PROTO_OUT_DIR}")

add_library(coreml_proto STATIC ${COREML_PROTOS})
protobuf_generate(
	TARGET coreml_proto
	LANGUAGE cpp
	IMPORT_DIRS "${PROTO_ROOT}"
	PROTOC_OUT_DIR "${PROTO_OUT_DIR}"
)
target_include_directories(coreml_proto PUBLIC
	"$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>"
	"$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/coremltools>"
)
target_link_libraries(coreml_proto PUBLIC protobuf::libprotobuf)

# MILBlob writer helpers and model package support
set(MLMODEL_SRC "${COREMLTOOLS_SOURCE_DIR}/mlmodel/src")
set(MODELPACKAGE_SRC "${COREMLTOOLS_SOURCE_DIR}/modelpackage/src")

add_library(mlmodel STATIC
	"${MLMODEL_SRC}/MILBlob/Fp16.cpp"
	"${MLMODEL_SRC}/MILBlob/Fp8.cpp"
	"${MLMODEL_SRC}/MILBlob/SubByteTypes.cpp"
	"${MLMODEL_SRC}/MILBlob/Blob/FileWriter.cpp"
	"${MLMODEL_SRC}/MILBlob/Blob/StorageWriter.cpp"
	"${MODELPACKAGE_SRC}/ModelPackage.cpp"
	"${MODELPACKAGE_SRC}/utils/JsonMap.cpp"
)
target_compile_features(mlmodel PUBLIC cxx_std_20)
target_include_directories(mlmodel
	PUBLIC
		"$<BUILD_INTERFACE:${MLMODEL_SRC}>"
		"$<BUILD_INTERFACE:${MODELPACKAGE_SRC}>"
		"$<BUILD_INTERFACE:${COREMLTOOLS_SOURCE_DIR}>"
		"$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/coremltools>"
		"$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/coremltools/mlmodel/src>"
		"$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/coremltools/modelpackage/src>"
)
get_target_property(NLOHMANN_JSON_INCLUDE_DIRS nlohmann_json::nlohmann_json INTERFACE_INCLUDE_DIRECTORIES)
foreach(dir IN LISTS NLOHMANN_JSON_INCLUDE_DIRS)
	# JsonMap.cpp includes "json.hpp" without the nlohmann/ prefix.
	target_include_directories(mlmodel PRIVATE "${dir}/nlohmann")
endforeach()
target_link_libraries(mlmodel PRIVATE nlohmann_json::nlohmann_json unofficial::fp16::fp16)
if(CMAKE_SYSTEM_NAME STREQUAL "Linux" OR CMAKE_SYSTEM_NAME STREQUAL "Android")
	target_link_libraries(mlmodel PRIVATE unofficial::UUID::uuid)
endif()

install(
	TARGETS coreml_proto mlmodel
	EXPORT unofficial-coremltools-targets
	RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
	LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
	ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
)

install(
	DIRECTORY "${MLMODEL_SRC}/MILBlob"
	DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/coremltools/mlmodel/src"
	FILES_MATCHING PATTERN "*.hpp"
	PATTERN "MMapFileReader*" EXCLUDE
	PATTERN "StorageReader*" EXCLUDE
)
install(
	FILES "${MODELPACKAGE_SRC}/ModelPackage.hpp"
	DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/coremltools/modelpackage/src"
)
install(
	DIRECTORY "${PROTO_OUT_DIR}"
	DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/coremltools"
	FILES_MATCHING PATTERN "*.h"
)

install(
	EXPORT unofficial-coremltools-targets
	NAMESPACE unofficial::coremltools::
	DESTINATION "${CMAKE_INSTALL_DATADIR}/unofficial-coremltools"
)

include(CMakePackageConfigHelpers)
configure_package_config_file(
	"${CMAKE_CURRENT_SOURCE_DIR}/unofficial-coremltools-config.cmake.in"
	"${CMAKE_CURRENT_BINARY_DIR}/unofficial-coremltools-config.cmake"
	INSTALL_DESTINATION "${CMAKE_INSTALL_DATADIR}/unofficial-coremltools"
)
install(
	FILES "${CMAKE_CURRENT_BINARY_DIR}/unofficial-coremltools-config.cmake"
	DESTINATION "${CMAKE_INSTALL_DATADIR}/unofficial-coremltools"
)
