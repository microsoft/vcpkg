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
  message(FATAL_ERROR "DirectXTK only supports dynamic CRT linkage")
endif()

set(DIRECTXTK_VERSION dec2017)
set(DIRECTXTK_ARCHIVE_HASH 30df95c17d6d61bdeb372d3ba112995ad76753e23ddaf7fb104d2384e3b26e22a383355d2a411fdfce866d4a98205e4ed039a8f34a9e1d9bc1ee90b4064bcd15)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK
    REF ${DIRECTXTK_VERSION}
    SHA512 ${DIRECTXTK_ARCHIVE_HASH}
    HEAD_REF master
)

IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
	SET(BUILD_ARCH "Win32")
ELSE()
	SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/DirectXTK_Desktop_2017.sln
	PLATFORM ${BUILD_ARCH}
)

file(INSTALL
	${SOURCE_PATH}/Bin/Desktop_2017/${BUILD_ARCH}/Release/DirectXTK.lib
	DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL
	${SOURCE_PATH}/Bin/Desktop_2017/${BUILD_ARCH}/Debug/DirectXTK.lib
	DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

set(DXTK_TOOL_PATH ${CURRENT_PACKAGES_DIR}/tools/directxtk)
file(MAKE_DIRECTORY ${DXTK_TOOL_PATH})

file(INSTALL
	${SOURCE_PATH}/MakeSpriteFont/bin/Release/MakeSpriteFont.exe 
	DESTINATION ${DXTK_TOOL_PATH})

file(INSTALL
	${SOURCE_PATH}/XWBTool/Bin/Desktop_2017/${BUILD_ARCH}/Release/XWBTool.exe 
	DESTINATION ${DXTK_TOOL_PATH})

file(INSTALL
	${SOURCE_PATH}/Inc/
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/DirectXTK
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/directxtk RENAME copyright)
