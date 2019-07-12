include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(NOT VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    message(FATAL_ERROR "DirectXTex only supports dynamic CRT linkage")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTex
    REF ab5b42d82b22243ac7961d76d41624eeb440d979
    SHA512 d54219a2946247cbbaad8d35274be342883af49d83d71ba205f36324ad2940e5f932d34c6e0007ca80430a53b428917c8d4b1b0970557eb7b49bea22fae5d30c
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
