if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
if (VCPKG_CRT_LINKAGE STREQUAL static)
    message(FATAL_ERROR "Static linking of the CRT is not yet supported.")
endif()
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/ChakraCore
    REF v1.7.4
    SHA512 116ed75d3128f8d9e8ad5a12deed194e14403e05f495422b14277a31620a37b7c8324f04738947388393b0e204f7748bb81d90ebab3373a198db76b70f89f374
    HEAD_REF master
)

find_path(COR_H_PATH cor.h)
if(COR_H_PATH MATCHES "NOTFOUND")
    message(FATAL_ERROR "Could not find <cor.h>. Ensure the NETFXSDK is installed.")
endif()
get_filename_component(NETFXSDK_PATH "${COR_H_PATH}/../.." ABSOLUTE)

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/Build/Chakra.Core.sln
    OPTIONS "/p:DotNetSdkRoot=${NETFXSDK_PATH}/" "/p:CustomBeforeMicrosoftCommonTargets=${CMAKE_CURRENT_LIST_DIR}/no-warning-as-error.props"
)

file(INSTALL
    ${SOURCE_PATH}/lib/jsrt/ChakraCore.h
    ${SOURCE_PATH}/lib/jsrt/ChakraCommon.h
    ${SOURCE_PATH}/lib/jsrt/ChakraCommonWindows.h
    ${SOURCE_PATH}/lib/jsrt/ChakraDebug.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
file(INSTALL
    ${SOURCE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_debug/ChakraCore.dll
    ${SOURCE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_debug/ChakraCore.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
)
file(INSTALL
    ${SOURCE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_debug/Chakracore.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)
file(INSTALL
    ${SOURCE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_release/ChakraCore.dll
    ${SOURCE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_release/ChakraCore.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin
)
file(INSTALL
    ${SOURCE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_release/Chakracore.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)
file(INSTALL
    ${SOURCE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_release/ch.exe
    ${SOURCE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_release/GCStress.exe
    ${SOURCE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_release/rl.exe
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools/chakracore)
vcpkg_copy_pdbs()
file(INSTALL
    ${SOURCE_PATH}/LICENSE.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/ChakraCore RENAME copyright)
