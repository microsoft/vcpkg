# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)

include(vcpkg_common_functions)

cmake_minimum_required(VERSION 3.8)

set(CMAKE_CXX_STANDARD 11)

set(VCPKG_BUILD_TYPE release)
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VERSION v2.4.1)
set(LIBRARY_VERSION 2.4.1)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/pulsar
    REF ${VERSION}
    SHA512 76e51000ceb180c3908cce395b12c2398d59453f0f4bb25917dc1b26e6a84e8a26e46e8e2905e9ff2c2796bc99dd3b21d19d46d0a99edcefee8182c4be7734d2
    HEAD_REF master
    PATCHES 
        "${CMAKE_CURRENT_LIST_DIR}/cmake-osx.patch"
        "${CMAKE_CURRENT_LIST_DIR}/schema.patch"
)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/v2.4.1-403c2b014b/pulsar-client-cpp)

if(WIN32)
  set(PROTOC_PATH ${CURRENT_INSTALLED_DIR}/tools/protobuf/protoc.exe)
else()
  set(PROTOC_PATH ${CURRENT_INSTALLED_DIR}/tools/protobuf/protoc)
endif()

set(PROTODIR ${SOURCE_PATH}/../pulsar-common/src/main/proto)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
    	-DPROTOC_PATH=${PROTOC_PATH}
        -DBUILD_TESTS=OFF 
        -DBUILD_PYTHON_WRAPPER=OFF
        -DLIB_NAME=pular
        -DLIBRARY_VERSION=${LIBRARY_VERSION}
)

vcpkg_install_cmake()

# Handle copyright
file(COPY ${SOURCE_PATH}/../LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libpulsar)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libpulsar/LICENSE ${CURRENT_PACKAGES_DIR}/share/libpulsar/copyright)

# Cleanup
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()