include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(NOT VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    message(FATAL_ERROR "DirectXTK only supports dynamic CRT linkage")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK
    REF dec2019
    SHA512 7a1f8e6b871552585ace70c2d40e02524c8aef274cec90cc93c25197c9eaa39f244d11082912083ad654df6f301da2076f36ac2195f3c9df278eefeda99af5a1
    HEAD_REF master
)

IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    SET(BUILD_ARCH "Win32")
ELSE()
    SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

if (VCPKG_PLATFORM_TOOLSET STREQUAL "v140")
    set(VS_VERSION "2015")
elseif (VCPKG_PLATFORM_TOOLSET STREQUAL "v141")
    set(VS_VERSION "2017")
elseif (VCPKG_PLATFORM_TOOLSET STREQUAL "v142")
    set(VS_VERSION "2019")
else()
    message(FATAL_ERROR "Unsupported platform toolset.")
endif()

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(SLN_NAME "Windows10_${VS_VERSION}")
else()
    if(TRIPLET_SYSTEM_ARCH STREQUAL "arm64")
        set(SLN_NAME "Desktop_${VS_VERSION}_Win10")
    else()
        set(SLN_NAME "Desktop_${VS_VERSION}")
    endif()
endif()

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/DirectXTK_${SLN_NAME}.sln
    PLATFORM ${BUILD_ARCH}
)

file(INSTALL
	${SOURCE_PATH}/Inc/
	DESTINATION ${CURRENT_PACKAGES_DIR}/include/DirectXTK
)

file(INSTALL
    ${SOURCE_PATH}/Bin/${SLN_NAME}/${BUILD_ARCH}/Release/DirectXTK.lib
    ${SOURCE_PATH}/Bin/${SLN_NAME}/${BUILD_ARCH}/Release/DirectXTK.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL
    ${SOURCE_PATH}/Bin/${SLN_NAME}/${BUILD_ARCH}/Debug/DirectXTK.lib
    ${SOURCE_PATH}/Bin/${SLN_NAME}/${BUILD_ARCH}/Debug/DirectXTK.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

if(NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(DXTK_TOOL_PATH ${CURRENT_PACKAGES_DIR}/tools/directxtk)
    file(MAKE_DIRECTORY ${DXTK_TOOL_PATH})
    file(INSTALL
        ${SOURCE_PATH}/MakeSpriteFont/bin/Release/MakeSpriteFont.exe
        DESTINATION ${DXTK_TOOL_PATH})
    file(INSTALL
        ${SOURCE_PATH}/XWBTool/Bin/Desktop_${VS_VERSION}/${BUILD_ARCH}/Release/XWBTool.exe
        DESTINATION ${DXTK_TOOL_PATH})
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
