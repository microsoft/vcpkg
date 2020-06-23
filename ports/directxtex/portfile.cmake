vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF jun2020b
    SHA512 e6b978c2c01f7ed4440cf60df65bcf795cc772af4f4f7e6b32e02c32575bc6f779fad45c137ab6b69871463abb4800532318d9e95e12d9a9c0e52197d20c5bd1
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

if(VCPKG_TARGET_IS_UWP)
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
    PLATFORM ${TRIPLET_SYSTEM_ARCH}
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

if(NOT VCPKG_TARGET_IS_UWP AND NOT TRIPLET_SYSTEM_ARCH STREQUAL "arm64")
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
