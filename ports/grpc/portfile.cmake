if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO grpc/grpc
    REF 591d56e1300b6d11948e1b821efac785a295989c # v1.44.0
    SHA512 b24f82768eed95b017a499ffb539af1f59d6916ab2da5ffb1de344ea7b0b7df536d1bb29a9bcb273bd84bc1f11b62383dc6c7df62e50d57621228f5aeeca6d5d
    HEAD_REF master
    PATCHES
        00001-fix-uwp.patch
        00002-static-linking-in-linux.patch
        00003-undef-base64-macro.patch
        00004-link-gdi32-on-windows.patch
        00005-fix-uwp-error.patch
        00006-fix-uwp-error.patch
        00009-use-system-upb.patch
        00010-add-feature-absl-sync.patch
        00011-fix-csharp_plugin.patch
        snprintf.patch
        00012-fix-use-cxx17.patch
        00013-build-upbdefs.patch
        00014-pkgconfig-upbdefs.patch
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
        absl-sync gRPC_ABSL_SYNC_ENABLE
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
        -DgRPC_UPB_PROVIDER=package
        -DgRPC_RE2_PROVIDER=package
        -DgRPC_PROTOBUF_PACKAGE_TYPE=CONFIG
        -DgRPC_CARES_PROVIDER=${cares_CARES_PROVIDER}
        -DgRPC_BENCHMARK_PROVIDER=none
        -DgRPC_INSTALL_BINDIR:STRING=bin
        -DgRPC_INSTALL_LIBDIR:STRING=lib
        -DgRPC_INSTALL_INCLUDEDIR:STRING=include
        -DgRPC_INSTALL_CMAKEDIR:STRING=share/grpc
        -D_gRPC_PROTOBUF_PROTOC_EXECUTABLE="${CURRENT_HOST_INSTALLED_DIR}/tools/protobuf/protoc${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        -DPROTOBUF_PROTOC_EXECUTABLE="${CURRENT_HOST_INSTALLED_DIR}/tools/protobuf/protoc${VCPKG_HOST_EXECUTABLE_SUFFIX}"
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

# Ignore the C# extension DLL in bin/
SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
