vcpkg_fail_port_install(ON_TARGET osx linux uwp ON_CRT_LINKAGE static ON_LIBRARY_LINKAGE static)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/ChakraCore
    REF 63c5099027ebb4547c802d62c2d2a6a39ee7eff6 # v1.11.22
    SHA512 5de915db48f5a125d4e0e112671ad7447212e6c0165d6c634a855a1d334f0bd2f7c015ba8c58d55225dd75d4c6687e6807987b8354b82405eb87944b46313062
    HEAD_REF master
)

find_path(COR_H_PATH cor.h)
if(COR_H_PATH MATCHES "NOTFOUND")
    message(FATAL_ERROR "Could not find <cor.h>. Ensure the NETFXSDK is installed.")
endif()
get_filename_component(NETFXSDK_PATH "${COR_H_PATH}/../.." ABSOLUTE)

set(BUILDTREE_PATH ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})
file(REMOVE_RECURSE ${BUILDTREE_PATH})
file(COPY ${SOURCE_PATH}/ DESTINATION ${BUILDTREE_PATH})

set(CHAKRA_RUNTIME_LIB "static_library") # ChakraCore only supports static CRT linkage

vcpkg_build_msbuild(
    PROJECT_PATH ${BUILDTREE_PATH}/Build/Chakra.Core.sln
    OPTIONS
        "/p:DotNetSdkRoot=${NETFXSDK_PATH}/"
        "/p:CustomBeforeMicrosoftCommonTargets=${CMAKE_CURRENT_LIST_DIR}/no-warning-as-error.props"
        "/p:RuntimeLib=${CHAKRA_RUNTIME_LIB}"
)

file(INSTALL
    ${BUILDTREE_PATH}/lib/jsrt/ChakraCore.h
    ${BUILDTREE_PATH}/lib/jsrt/ChakraCommon.h
    ${BUILDTREE_PATH}/lib/jsrt/ChakraCommonWindows.h
    ${BUILDTREE_PATH}/lib/jsrt/ChakraDebug.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(INSTALL
        ${BUILDTREE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_debug/ChakraCore.dll
        ${BUILDTREE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_debug/ChakraCore.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
    )
    file(INSTALL
        ${BUILDTREE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_debug/Chakracore.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
    )
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(INSTALL
        ${BUILDTREE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_release/ChakraCore.dll
        ${BUILDTREE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_release/ChakraCore.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin
    )
    file(INSTALL
        ${BUILDTREE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_release/Chakracore.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    )
    file(INSTALL
        ${BUILDTREE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_release/ch.exe
        ${BUILDTREE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_release/GCStress.exe
        ${BUILDTREE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_release/rl.exe
        DESTINATION ${CURRENT_PACKAGES_DIR}/tools/chakracore)
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/chakracore)
endif()

vcpkg_copy_pdbs()
file(INSTALL
    ${SOURCE_PATH}/LICENSE.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/ChakraCore RENAME copyright)
