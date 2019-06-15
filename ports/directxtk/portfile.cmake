include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(NOT VCPKG_CRT_LINKAGE STREQUAL "dynamic")
  message(FATAL_ERROR "DirectXTK only supports dynamic CRT linkage")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK
    REF apr2019
    SHA512 811ed222c1650d34a8475e44719cca8972a85d96f9ccb10548e1501eb9d28fd8685de90832b517cdcbf21ae8c9160dea69000e8dca06fab745a15a7acc14ba98
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
