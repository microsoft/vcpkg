if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/DirectXTK-oct2016)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Microsoft/DirectXTK/archive/oct2016.tar.gz"
    FILENAME "oct2016.tar.gz"
    SHA512 b44ee28518ca65d38a3c915881ef79533b48b07d3738b616f1935d7c00a26d5e48b2292cde6acc34e933f85ba2a6362c585c60b2bbc704745d43cef53769a112
)
vcpkg_extract_source_archive(${ARCHIVE})

IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
	SET(BUILD_ARCH "Win32")
ELSE()
	SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/DirectXTK_Desktop_2015_Win10.sln
	PLATFORM ${BUILD_ARCH}
)

file(INSTALL
	${SOURCE_PATH}/Bin/Desktop_2015_Win10/${BUILD_ARCH}/Release/DirectXTK.lib
	DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL
	${SOURCE_PATH}/Bin/Desktop_2015_Win10/${BUILD_ARCH}/Debug/DirectXTK.lib
	DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

set(DXTK_TOOL_PATH ${CURRENT_PACKAGES_DIR}/tools/directxtk)
file(MAKE_DIRECTORY ${DXTK_TOOL_PATH})

file(INSTALL
	${SOURCE_PATH}/MakeSpriteFont/bin/Release/MakeSpriteFont.exe 
	DESTINATION ${DXTK_TOOL_PATH})

file(INSTALL
	${SOURCE_PATH}/XWBTool/Bin/Desktop_2015/${BUILD_ARCH}/Release/XWBTool.exe 
	DESTINATION ${DXTK_TOOL_PATH})

file(INSTALL
	${SOURCE_PATH}/Inc/
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/directxtk RENAME copyright)
