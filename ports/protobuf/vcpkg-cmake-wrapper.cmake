find_program(Protobuf_PROTOC_EXECUTABLE NAMES protoc PATHS "${CMAKE_CURRENT_LIST_DIR}/../../../@HOST_TRIPLET@/tools/protobuf" NO_DEFAULT_PATH)

vcpkg_underlying_find_package(${ARGS} CONFIG)
