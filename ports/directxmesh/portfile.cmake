include(vcpkg_common_functions)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

if(NOT VCPKG_CRT_LINKAGE STREQUAL "dynamic")
  message(FATAL_ERROR "DirectXMesh only supports dynamic CRT linkage")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXMesh
    REF 9f0b4e3591e528f09eb454681297d7bf22e2ee9a
    SHA512 38b8a62bb591c9da034ba3a3186a5c2a4144eba0c9ee3b4ed851a0fc9492a3bdd6f33e508206e0fe6d4b9b58241a10f1bd1b7de5a39691ce8dea51fbaf0e0c65
    HEAD_REF master
)

IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    SET(BUILD_ARCH "Win32")
ELSE()
    SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/DirectXMesh_Desktop_2017.sln
    PLATFORM ${BUILD_ARCH}
)

file(INSTALL
    ${SOURCE_PATH}/DirectXMesh/DirectXMesh.h
    ${SOURCE_PATH}/DirectXMesh/DirectXMesh.inl
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
file(INSTALL
    ${SOURCE_PATH}/DirectXMesh/Bin/Desktop_2017/${BUILD_ARCH}/Debug/DirectXMesh.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL
    ${SOURCE_PATH}/DirectXMesh/Bin/Desktop_2017/${BUILD_ARCH}/Release/DirectXMesh.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

set(TOOL_PATH ${CURRENT_PACKAGES_DIR}/tools)
file(INSTALL
    ${SOURCE_PATH}/Meshconvert/Bin/Desktop_2017/${BUILD_ARCH}/Release/Meshconvert.exe
    DESTINATION ${TOOL_PATH})

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/directxmesh)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/directxmesh/LICENSE ${CURRENT_PACKAGES_DIR}/share/directxmesh/copyright)
