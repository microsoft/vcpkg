if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()
include(vcpkg_common_functions)

set(GRPC_VERSION 1.2.3)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/grpc-${GRPC_VERSION})

if(EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/src)
endif()

vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/grpc/grpc/archive/v${GRPC_VERSION}.zip"
    FILENAME "grpc-v${GRPC_VERSION}.tar.gz"
    SHA512 1468ace60ce9affb563b8145d43793778786626bfd568c79ba9c9792bf05adb86e99dfd13ff21c4b723909fbddae583148201be1a694bc0960fbe10200f52544
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/revert-c019e05.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DgRPC_INSTALL=ON
        -DgRPC_ZLIB_PROVIDER=package
        -DgRPC_SSL_PROVIDER=package
        -DgRPC_PROTOBUF_PROVIDER=package
        -DCMAKE_INSTALL_CMAKEDIR=share/grpc
)

vcpkg_install_cmake()

# Update paths in gRPCTargets-release.cmake
file(READ ${CURRENT_PACKAGES_DIR}/share/grpc/gRPCTargets-release.cmake _contents)
string(REPLACE "\${_IMPORT_PREFIX}/bin/" "\${_IMPORT_PREFIX}/tools/" _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/grpc/gRPCTargets-release.cmake "${_contents}")

# Update paths in gRPCTargets-debug.cmake
file(READ ${CURRENT_PACKAGES_DIR}/debug/share/grpc/gRPCTargets-debug.cmake _contents)
string(REPLACE "\${_IMPORT_PREFIX}/bin/" "\${_IMPORT_PREFIX}/tools/" _contents "${_contents}")
string(REPLACE "\${_IMPORT_PREFIX}/lib/" "\${_IMPORT_PREFIX}/debug/lib/" _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/grpc/gRPCTargets-debug.cmake "${_contents}")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/grpc RENAME copyright)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)

# Install tools and plugins
file(GLOB TOOLS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.exe")
if(TOOLS)
    file(COPY ${TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()
