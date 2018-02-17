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
  message(FATAL_ERROR "DirectXTex only supports dynamic CRT linkage")
endif()

set(DIRECTXTEX_VERSION dec2017)
set(DIRECTXTEX_ARCHIVE_HASH f4154c820059893ce0a42a1224d14adc0f8b54f36aa7f687f29aba0358488da9eb83cbdbf682499c5b210e99607d74209595153d4ed86eb30c43b775c5d8a72f)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF ${DIRECTXTEX_VERSION}
    SHA512 ${DIRECTXTEX_ARCHIVE_HASH}
    HEAD_REF master
)

IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    SET(BUILD_ARCH "Win32")
ELSE()
    SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/DirectXTex_Desktop_2017.sln
    PLATFORM ${BUILD_ARCH}
)

file(INSTALL
    ${SOURCE_PATH}/DirectXTex/DirectXTex.h
    ${SOURCE_PATH}/DirectXTex/DirectXTex.inl
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
file(INSTALL
    ${SOURCE_PATH}/DirectXTex/Bin/Desktop_2017/${BUILD_ARCH}/Debug/DirectXTex.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL
    ${SOURCE_PATH}/DirectXTex/Bin/Desktop_2017/${BUILD_ARCH}/Release/DirectXTex.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

set(TOOL_PATH ${CURRENT_PACKAGES_DIR}/tools)
file(MAKE_DIRECTORY ${TOOL_PATH})
file(INSTALL
    ${SOURCE_PATH}/Texdiag/Bin/Desktop_2017/${BUILD_ARCH}/Release/texdiag.exe
    DESTINATION ${TOOL_PATH})
file(INSTALL
    ${SOURCE_PATH}/Texconv/Bin/Desktop_2017/${BUILD_ARCH}/Release/Texconv.exe
    DESTINATION ${TOOL_PATH})
file(INSTALL
    ${SOURCE_PATH}/Texassemble/Bin/Desktop_2017/${BUILD_ARCH}/Release/Texassemble.exe
    DESTINATION ${TOOL_PATH})

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/DirectXTex)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/DirectXTex/LICENSE ${CURRENT_PACKAGES_DIR}/share/DirectXTex/copyright)
