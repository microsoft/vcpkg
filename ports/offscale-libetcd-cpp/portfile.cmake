vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO offscale/libetcd-cpp
    REF 8607d8d7080c6eb447bc41b799a24bfdb87cf638
    SHA512 9bf4bf14fd52f4f6bbf8cf68de61e6a19eeffbdc501f05c8f614b5f13f206410884afd7fe226a077448e58e02990c65a6b27ee895ed34ba5ee701abe0500b875
    HEAD_REF master
    PATCHES
        fix-dependency-grpc.patch
        install-debug.patch
        fix-crosscompile-protobuf-grpc.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE # see https://github.com/microsoft/vcpkg/pull/21168#issuecomment-961588989 why
    OPTIONS
        "-DProtobuf_PROTOC_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/protobuf/protoc${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        "-DgRPC_CPP_PLUGIN=${CURRENT_HOST_INSTALLED_DIR}/tools/grpc/grpc_cpp_plugin${VCPKG_HOST_EXECUTABLE_SUFFIX}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME etcdcpp)
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE-MIT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
