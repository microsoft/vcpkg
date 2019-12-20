include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(NOT VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    message(FATAL_ERROR "DirectXTex only supports dynamic CRT linkage")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF dec2019
    SHA512 b0c7fdeb2f035186eddeb543cd16813c6807b9646367cd309082bd164ab484001dee912249d5570e3ddf5abb90cb3e7c0355a3c18c2e2bd2a051292b65a293f6
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
    PROJECT_PATH ${SOURCE_PATH}/DirectXTex_${SLN_NAME}.sln
    PLATFORM ${BUILD_ARCH}
)

file(INSTALL
    ${SOURCE_PATH}/DirectXTex/DirectXTex.h
    ${SOURCE_PATH}/DirectXTex/DirectXTex.inl
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
file(INSTALL
    ${SOURCE_PATH}/DirectXTex/Bin/${SLN_NAME}/${BUILD_ARCH}/Debug/DirectXTex.lib
    ${SOURCE_PATH}/DirectXTex/Bin/${SLN_NAME}/${BUILD_ARCH}/Debug/DirectXTex.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL
    ${SOURCE_PATH}/DirectXTex/Bin/${SLN_NAME}/${BUILD_ARCH}/Release/DirectXTex.lib
    ${SOURCE_PATH}/DirectXTex/Bin/${SLN_NAME}/${BUILD_ARCH}/Release/DirectXTex.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

if(NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" AND NOT TRIPLET_SYSTEM_ARCH STREQUAL "arm64")
    set(TOOL_PATH ${CURRENT_PACKAGES_DIR}/tools/directxtex)
    file(MAKE_DIRECTORY ${TOOL_PATH})
    file(INSTALL
        ${SOURCE_PATH}/Texdiag/Bin/${SLN_NAME}/${BUILD_ARCH}/Release/texdiag.exe
        DESTINATION ${TOOL_PATH})
    file(INSTALL
        ${SOURCE_PATH}/Texconv/Bin/${SLN_NAME}/${BUILD_ARCH}/Release/Texconv.exe
        DESTINATION ${TOOL_PATH})
    file(INSTALL
        ${SOURCE_PATH}/Texassemble/Bin/${SLN_NAME}/${BUILD_ARCH}/Release/Texassemble.exe
        DESTINATION ${TOOL_PATH})
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
