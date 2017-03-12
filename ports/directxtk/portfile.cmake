if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/DirectXTK-dec2016)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Microsoft/DirectXTK/archive/dec2016.tar.gz"
    FILENAME "DirectXTK-dec2016.tar.gz"
    SHA512 efb8a98d0872bf1835b274ba88615e88c4a58ab753c5ebef5a407c54d5f9a2197d1521f14651c60ea16c047918db6f54bf2ac58a6eb7330490b9bae619e8dad3
)
vcpkg_extract_source_archive(${ARCHIVE})

IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
	SET(BUILD_ARCH "Win32")
ELSE()
	SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/DirectXTK_Desktop_2015.sln
	PLATFORM ${BUILD_ARCH}
)

file(INSTALL
	${SOURCE_PATH}/Bin/Desktop_2015/${BUILD_ARCH}/Release/DirectXTK.lib
	DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL
	${SOURCE_PATH}/Bin/Desktop_2015/${BUILD_ARCH}/Debug/DirectXTK.lib
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
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/DirectXTK
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/directxtk RENAME copyright)
