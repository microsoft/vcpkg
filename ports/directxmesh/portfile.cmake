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
#
include(vcpkg_common_functions)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

if(NOT VCPKG_CRT_LINKAGE STREQUAL "dynamic")
  message(FATAL_ERROR "DirectXMesh only supports dynamic CRT linkage")
endif()

set(DIRECTXMESH_VERSION dec2017)
set(DIRECTXMESH_ARCHIVE_HASH 82468f1fcf0d51cf614921b1bd2dd06a05b120f84531d59429042951a39d1e978b5395cdf75269fe1767789ce487bfc6e544c54df4b1b9bec9adb1c853dc8497)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXMesh
    REF ${DIRECTXMESH_VERSION}
    SHA512 ${DIRECTXMESH_ARCHIVE_HASH}
    HEAD_REF master
)

IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    SET(BUILD_ARCH "Win32")
ELSE()
    SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/DirectXMesh_Desktop_2017.sln
    PLATFORM ${BUILD_ARCH}
)

file(INSTALL
    ${SOURCE_PATH}/DirectXMesh/DirectXMesh.h
    ${SOURCE_PATH}/DirectXMesh/DirectXMesh.inl
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
file(INSTALL
    ${SOURCE_PATH}/DirectXMesh/Bin/Desktop_2017/${BUILD_ARCH}/Debug/DirectXMesh.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL
    ${SOURCE_PATH}/DirectXMesh/Bin/Desktop_2017/${BUILD_ARCH}/Release/DirectXMesh.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

set(TOOL_PATH ${CURRENT_PACKAGES_DIR}/tools)
file(INSTALL
    ${SOURCE_PATH}/Meshconvert/Bin/Desktop_2017/${BUILD_ARCH}/Release/Meshconvert.exe
    DESTINATION ${TOOL_PATH})

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/directxmesh)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/directxmesh/LICENSE ${CURRENT_PACKAGES_DIR}/share/directxmesh/copyright)
