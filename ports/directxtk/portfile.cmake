include(vcpkg_common_functions)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

if(NOT VCPKG_CRT_LINKAGE STREQUAL "dynamic")
  message(FATAL_ERROR "DirectXTK only supports dynamic CRT linkage")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXTK
    REF may2018
    SHA512 0d492fcd72882aa91270b8fbaf9caa897bf4499931921fdded052129ecbb5476a373fa32ac0870897bc5ead9dae749f9b52e86fc617654f64b263041001cdfb5
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
