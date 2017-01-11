# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/DirectXMesh-oct2016)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Microsoft/DirectXMesh/archive/oct2016.tar.gz"
    FILENAME "DirectXMesh-oct2016.tar.gz"
    SHA512 8aaf9749766afd23709ce6c6f8d74b008fe9f96789e4d97cb387633dad34b4132ef28dfe028d13c779ea366428d53076a881c0d63c4f0c2c74d552293c8d6bf1
)
vcpkg_extract_source_archive(${ARCHIVE})

IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
	SET(BUILD_ARCH "Win32")
ELSE()
	SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/DirectXMesh_Desktop_2015.sln
	PLATFORM ${BUILD_ARCH}
)

file(INSTALL
	${SOURCE_PATH}/DirectXMesh/DirectXMesh.h
	${SOURCE_PATH}/DirectXMesh/DirectXMesh.inl
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
file(INSTALL
	${SOURCE_PATH}/DirectXMesh/Bin/Desktop_2015/${BUILD_ARCH}/Debug/DirectXMesh.lib
	DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL
	${SOURCE_PATH}/DirectXMesh/Bin/Desktop_2015/${BUILD_ARCH}/Release/DirectXMesh.lib
	DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

set(TOOL_PATH ${CURRENT_PACKAGES_DIR}/tools)
file(INSTALL
	${SOURCE_PATH}/Meshconvert/Bin/Desktop_2015/${BUILD_ARCH}/Release/Meshconvert.exe
	DESTINATION ${TOOL_PATH})

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/directxmesh)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/directxmesh/LICENSE ${CURRENT_PACKAGES_DIR}/share/directxmesh/copyright)
