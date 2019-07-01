include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" OR NOT VCPKG_CMAKE_SYSTEM_NAME)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

# This snippet is a workaround for users who are upgrading from an extremely old version of this
# port, which cloned directly into `src\`
if(EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/src)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO grpc/grpc
    REF 75475f090875e737ad6909a6057c59577f0c79b1
    SHA512 db9ff82dee38cb0f4ba10874d10bf6cb20c8a4d49e7dd24bcd9f71388c54c782ee12fda6f1bfedd79ad988b0275d3f96df4686217465acfafcfb5e4c30093a5b
    HEAD_REF master
    PATCHES
        00001-fix-uwp.patch
        00002-static-linking-in-linux.patch
        00003-undef-base64-macro.patch
        00004-link-gdi32-on-windows.patch
)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(gRPC_BUILD_CODEGEN OFF)
else()
    set(gRPC_BUILD_CODEGEN ON)
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(gRPC_MSVC_STATIC_RUNTIME ON)
else()
    set(gRPC_MSVC_STATIC_RUNTIME OFF)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(gRPC_STATIC_LINKING ON)
else()
    set(gRPC_STATIC_LINKING OFF)
endif()

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(cares_CARES_PROVIDER OFF)
else()
    set(cares_CARES_PROVIDER "package")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DgRPC_INSTALL=ON
        -DgRPC_BUILD_TESTS=OFF
        -DgRPC_STATIC_LINKING=${gRPC_STATIC_LINKING}
        -DgRPC_MSVC_STATIC_RUNTIME=${gRPC_MSVC_STATIC_RUNTIME}
        -DgRPC_ZLIB_PROVIDER=package
        -DgRPC_SSL_PROVIDER=package
        -DgRPC_PROTOBUF_PROVIDER=package
        -DgRPC_PROTOBUF_PACKAGE_TYPE=CONFIG
        -DgRPC_CARES_PROVIDER=${cares_CARES_PROVIDER}
        -DgRPC_GFLAGS_PROVIDER=none
        -DgRPC_BENCHMARK_PROVIDER=none
        -DgRPC_INSTALL_CSHARP_EXT=OFF
        -DgRPC_INSTALL_BINDIR:STRING=tools/grpc
        -DgRPC_INSTALL_LIBDIR:STRING=lib
        -DgRPC_INSTALL_INCLUDEDIR:STRING=include
        -DgRPC_INSTALL_CMAKEDIR:STRING=share/grpc
        -DgRPC_BUILD_CODEGEN=${gRPC_BUILD_CODEGEN}
)

vcpkg_install_cmake(ADD_BIN_TO_PATH)

vcpkg_fixup_cmake_targets()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/grpc RENAME copyright)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/grpc)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/tools")

# Ignore the C# extension DLL in bin/
SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()
