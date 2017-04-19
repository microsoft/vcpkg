if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()
include(vcpkg_common_functions)

set(GRPC_VERSION 1.1.2)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/grpc-${GRPC_VERSION})

if(EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/src)
endif()

vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/grpc/grpc/archive/v${GRPC_VERSION}.zip"
    FILENAME "grpc-v${GRPC_VERSION}.tar.gz"
    SHA512 6e0666ecb72f0a78148fadf627e05b5ba0f1c893919f1e691775d09374e7c4b9b05ff1d276e716ac2a81eb2a3fb88c4a095928589286d2f083bd60539050f5d9
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

# patch is from https://github.com/grpc/grpc/commit/a5fac1f8a00b0ba6ca784baa4783ab947579693b
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/grpc-fix-cmake-build.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DgRPC_INSTALL=ON
        -DgRPC_ZLIB_PROVIDER=package
        -DgRPC_SSL_PROVIDER=package
        -DgRPC_PROTOBUF_PROVIDER=package
)

vcpkg_install_cmake()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/grpc)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/gRPC/gRPCConfig.cmake ${CURRENT_PACKAGES_DIR}/share/grpc/gRPCConfig.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/gRPC/gRPCConfigVersion.cmake ${CURRENT_PACKAGES_DIR}/share/grpc/gRPCConfigVersion.cmake)

# Update import target prefix in gRPCTargets.cmake
file(READ ${CURRENT_PACKAGES_DIR}/lib/cmake/gRPC/gRPCTargets.cmake _contents)
set(pattern "get_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\n")
string(REPLACE "${pattern}${pattern}" "${pattern}" _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/grpc/gRPCTargets.cmake "${_contents}")

# Update paths in gRPCTargets-release.cmake
file(READ ${CURRENT_PACKAGES_DIR}/lib/cmake/gRPC/gRPCTargets-release.cmake _contents)
string(REPLACE "\${_IMPORT_PREFIX}/bin/" "\${_IMPORT_PREFIX}/tools/" _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/grpc/gRPCTargets-release.cmake "${_contents}")

# Update paths in gRPCTargets-debug.cmake
file(READ ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/gRPC/gRPCTargets-debug.cmake _contents)
string(REPLACE "\${_IMPORT_PREFIX}/bin/" "\${_IMPORT_PREFIX}/tools/" _contents "${_contents}")
string(REPLACE "\${_IMPORT_PREFIX}/lib/" "\${_IMPORT_PREFIX}/debug/lib/" _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/grpc/gRPCTargets-debug.cmake "${_contents}")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/grpc RENAME copyright)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/grpc_cpp_plugin.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools)

# Install tools and plugins
file(
    INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools
    FILES_MATCHING PATTERN "*.exe"
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)

vcpkg_copy_pdbs()
