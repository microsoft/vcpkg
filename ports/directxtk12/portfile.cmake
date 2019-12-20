include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(NOT VCPKG_CRT_LINKAGE STREQUAL "dynamic")
  message(FATAL_ERROR "DirectXTK12 only supports dynamic CRT linkage")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK12
    REF dec2019
    SHA512 2144c7a51ea73efea5ad4db3b0b92bfc5a2ca57c38e7f6702ce82a09049266a3aaad4500856a964c4069aa711973d3a10cb3b133397ec93bda3a4a0328b9d81c
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
    set(SLN_NAME "Desktop_${VS_VERSION}_Win10")
endif()

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/DirectXTK_${SLN_NAME}.sln
)

file(INSTALL
	${SOURCE_PATH}/Inc/
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/DirectXTK12
)

file(INSTALL
    ${SOURCE_PATH}/Bin/${SLN_NAME}/${BUILD_ARCH}/Release/DirectXTK12.lib
    ${SOURCE_PATH}/Bin/${SLN_NAME}/${BUILD_ARCH}/Release/DirectXTK12.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL
    ${SOURCE_PATH}/Bin/${SLN_NAME}/${BUILD_ARCH}/Debug/DirectXTK12.lib
    ${SOURCE_PATH}/Bin/${SLN_NAME}/${BUILD_ARCH}/Debug/DirectXTK12.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
