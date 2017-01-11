# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#
if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/directxtex-dec2016)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Microsoft/DirectXTex/archive/dec2016.tar.gz"
    FILENAME "directxtex-dec2016.tar.gz"
    SHA512 87797340c40a98a7b11b6eb7da17d0b93bc01ba48deed50e99ce74e0e33387cac2ec18f2f14d0148c2a79f97ca98d6b2a228dad2f16010b6dcf03c0d24a79d20
)
vcpkg_extract_source_archive(${ARCHIVE})

IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
	SET(BUILD_ARCH "Win32")
ELSE()
	SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/DirectXTex_Desktop_2015.sln
	PLATFORM ${BUILD_ARCH}
)

file(INSTALL
	${SOURCE_PATH}/DirectXTex/DirectXTex.h
	${SOURCE_PATH}/DirectXTex/DirectXTex.inl
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
file(INSTALL
	${SOURCE_PATH}/DirectXTex/Bin/Desktop_2015/${BUILD_ARCH}/Debug/DirectXTex.lib
	DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL
	${SOURCE_PATH}/DirectXTex/Bin/Desktop_2015/${BUILD_ARCH}/Release/DirectXTex.lib
	DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

set(TOOL_PATH ${CURRENT_PACKAGES_DIR}/tools)
file(MAKE_DIRECTORY ${TOOL_PATH})
file(INSTALL
	${SOURCE_PATH}/Texdiag/Bin/Desktop_2015/${BUILD_ARCH}/Release/texdiag.exe
	DESTINATION ${TOOL_PATH})
file(INSTALL
	${SOURCE_PATH}/Texconv/Bin/Desktop_2015/${BUILD_ARCH}/Release/Texconv.exe
	DESTINATION ${TOOL_PATH})
file(INSTALL
	${SOURCE_PATH}/Texassemble/Bin/Desktop_2015/${BUILD_ARCH}/Release/Texassemble.exe
	DESTINATION ${TOOL_PATH})

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/DirectXTex)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/DirectXTex/LICENSE ${CURRENT_PACKAGES_DIR}/share/DirectXTex/copyright)
