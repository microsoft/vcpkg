if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO grpc/grpc
    REF 7d89dbb311f049b43bda7bbf6f7d7bf1b4c24419 #v1.29.1
    SHA512 403fa5e3f012786bb17ca32c760b6dfb22c5a5cfb473ba7fad657e26ab3986eb0203f7cbb501a8647fd5ef2571e5f4ee08c2c97d1dfda18ec5ab6a92c9fc3263
    HEAD_REF master
    PATCHES
        00001-fix-uwp.patch
        00002-static-linking-in-linux.patch
        00003-undef-base64-macro.patch
        00004-link-gdi32-on-windows.patch
        00005-fix-uwp-error.patch
        00009-use-system-upb.patch
        00010-add-feature-absl-sync.patch
        00011-fix-csharp_plugin.patch
        snprintf.patch
)

if(VCPKG_TARGET_IS_UWP OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(gRPC_BUILD_CODEGEN OFF)
else()
    set(gRPC_BUILD_CODEGEN ON)
endif()

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" gRPC_MSVC_STATIC_RUNTIME)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" gRPC_STATIC_LINKING)

if(VCPKG_TARGET_IS_UWP)
    set(cares_CARES_PROVIDER OFF)
else()
    set(cares_CARES_PROVIDER "package")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    absl-sync gRPC_ABSL_SYNC_ENABLE
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
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
        -DgRPC_PROTOBUF_PACKAGE_TYPE=CONFIG
        -DgRPC_CARES_PROVIDER=${cares_CARES_PROVIDER}
        -DgRPC_GFLAGS_PROVIDER=none
        -DgRPC_BENCHMARK_PROVIDER=none
        -DgRPC_INSTALL_CSHARP_EXT=OFF
        -DgRPC_INSTALL_BINDIR:STRING=tools/grpc
        -DgRPC_INSTALL_LIBDIR:STRING=lib
        -DgRPC_INSTALL_INCLUDEDIR:STRING=include
        -DgRPC_INSTALL_CMAKEDIR:STRING=share/gRPC
        -DgRPC_BUILD_CODEGEN=${gRPC_BUILD_CODEGEN}
)

vcpkg_install_cmake(ADD_BIN_TO_PATH)

vcpkg_fixup_cmake_targets(CONFIG_PATH share/gRPC TARGET_PATH share/gRPC)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/grpc RENAME copyright)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/grpc)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/tools")

# Ignore the C# extension DLL in bin/
SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()
