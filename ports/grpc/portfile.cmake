if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO grpc/grpc
    REF "v${VERSION}"
    SHA512 91c2406ed4198509ac0d5360b3da6898fa4f40f459eb6fff541faa44cc238eed98fd7489e7ef7a80a6f4a318bc5b9130eaa0ba1beaa358d1c074fc82825648ff
    HEAD_REF master
    PATCHES
        00001-fix-uwp.patch
        00002-static-linking-in-linux.patch
        00003-undef-base64-macro.patch
        00004-link-gdi32-on-windows.patch
        00005-fix-uwp-error.patch
        00009-use-system-upb.patch
        00015-disable-download-archive.patch
        00016-fix-plugin-targets.patch
        00017-abseil.patch
)

if(NOT TARGET_TRIPLET STREQUAL HOST_TRIPLET)
    vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/grpc")
endif()

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" gRPC_MSVC_STATIC_RUNTIME)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" gRPC_STATIC_LINKING)

if(VCPKG_TARGET_IS_UWP)
    set(cares_CARES_PROVIDER OFF)
else()
    set(cares_CARES_PROVIDER "package")
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        codegen gRPC_BUILD_CODEGEN
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DgRPC_INSTALL=ON
        -DgRPC_BUILD_TESTS=OFF
        -DgRPC_STATIC_LINKING=${gRPC_STATIC_LINKING}
        -DgRPC_MSVC_STATIC_RUNTIME=${gRPC_MSVC_STATIC_RUNTIME}
        -DgRPC_ZLIB_PROVIDER=package
        -DgRPC_SSL_PROVIDER=package
        -DgRPC_PROTOBUF_PROVIDER=package
        -DgRPC_ABSL_PROVIDER=package
        -DgRPC_RE2_PROVIDER=package
        -DgRPC_CARES_PROVIDER=${cares_CARES_PROVIDER}
        -DgRPC_BENCHMARK_PROVIDER=none
        -DgRPC_INSTALL_BINDIR:STRING=bin
        -DgRPC_INSTALL_LIBDIR:STRING=lib
        -DgRPC_INSTALL_INCLUDEDIR:STRING=include
        -DgRPC_INSTALL_CMAKEDIR:STRING=share/grpc
        "-D_gRPC_PROTOBUF_PROTOC_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/protobuf/protoc${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        "-DProtobuf_PROTOC_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/protobuf/protoc${VCPKG_HOST_EXECUTABLE_SUFFIX}"
    MAYBE_UNUSED_VARIABLES
        gRPC_MSVC_STATIC_RUNTIME
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)

vcpkg_cmake_config_fixup()

if (gRPC_BUILD_CODEGEN)
    vcpkg_copy_tools(
        AUTO_CLEAN
        TOOL_NAMES
            grpc_php_plugin
            grpc_python_plugin
            grpc_node_plugin
            grpc_objective_c_plugin
            grpc_csharp_plugin
            grpc_cpp_plugin
            grpc_ruby_plugin
    )
else()
    configure_file("${CMAKE_CURRENT_LIST_DIR}/gRPCTargets-vcpkg-tools.cmake" "${CURRENT_PACKAGES_DIR}/share/grpc/gRPCTargets-vcpkg-tools.cmake" @ONLY)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
if (VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
else()
    vcpkg_fixup_pkgconfig()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
