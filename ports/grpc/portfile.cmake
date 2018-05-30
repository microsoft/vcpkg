if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)

if(EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/src)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO grpc/grpc
    REF v1.10.1
    SHA512 2221d902c60eada6dd1547a63d26bd3b30cb6710247b5e48523bacde498a3691cc177f1dbe9db8a007b8ae341a5b0c8ec999539e26a9bcff480a8d0b02140997
    HEAD_REF master
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/disable-csharp-ext.patch
        ${CMAKE_CURRENT_LIST_DIR}/disable-csharp-ext-2.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-uwp.patch
)

if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(gRPC_MSVC_STATIC_RUNTIME ON)
else()
    set(gRPC_MSVC_STATIC_RUNTIME OFF)
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
        -DgRPC_MSVC_STATIC_RUNTIME=${gRPC_MSVC_STATIC_RUNTIME}
        -DgRPC_ZLIB_PROVIDER=package
        -DgRPC_SSL_PROVIDER=package
        -DgRPC_PROTOBUF_PROVIDER=package
        -DgRPC_CARES_PROVIDER=${cares_CARES_PROVIDER}
        -DgRPC_GFLAGS_PROVIDER=none
        -DgRPC_BENCHMARK_PROVIDER=none
        -DgRPC_INSTALL_CSHARP_EXT=OFF
        -DgRPC_INSTALL_BINDIR:STRING=bin
        -DgRPC_INSTALL_LIBDIR:STRING=lib
        -DgRPC_INSTALL_INCLUDEDIR:STRING=include
        -DgRPC_INSTALL_CMAKEDIR:STRING=share/grpc
)

# gRPC runs built executables during the build, so they need access to the installed DLLs.
set(ENV{PATH} "$ENV{PATH};${CURRENT_INSTALLED_DIR}/bin;${CURRENT_INSTALLED_DIR}/debug/bin")

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "share/grpc")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/grpc RENAME copyright)

# Install tools and plugins
file(GLOB TOOLS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.exe")
if(TOOLS)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/grpc)
    file(COPY ${TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/grpc)
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/grpc)
endif()

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    SET(VCPKG_POLICY_EMPTY_PACKAGE enabled) # Leave the executable files in bin/ and debug/bin
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()
