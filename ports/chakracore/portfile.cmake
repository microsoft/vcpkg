if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
if(VCPKG_CRT_LINKAGE STREQUAL static)
    message(FATAL_ERROR "Static linking of the CRT is not yet supported.")
endif()

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "UWP is not currently supported.")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/ChakraCore
    REF v1.8.2
    SHA512 6d4408311f0c3ff2c9895f59f34f12fb84797d130a562db7c2af27eb26edd3d46bf935dab4cd40c2ffc0dc853ad9bdf432a721cfded7836639858965b7eb67e9
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

vcpkg_build_msbuild(
    PROJECT_PATH ${BUILDTREE_PATH}/Build/Chakra.Core.sln
    OPTIONS "/p:DotNetSdkRoot=${NETFXSDK_PATH}/" "/p:CustomBeforeMicrosoftCommonTargets=${CMAKE_CURRENT_LIST_DIR}/no-warning-as-error.props"
)

file(INSTALL
    ${BUILDTREE_PATH}/lib/jsrt/ChakraCore.h
    ${BUILDTREE_PATH}/lib/jsrt/ChakraCommon.h
    ${BUILDTREE_PATH}/lib/jsrt/ChakraCommonWindows.h
    ${BUILDTREE_PATH}/lib/jsrt/ChakraDebug.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
file(INSTALL
    ${BUILDTREE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_debug/ChakraCore.dll
    ${BUILDTREE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_debug/ChakraCore.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
)
file(INSTALL
    ${BUILDTREE_PATH}/Build/VcBuild/bin/${TRIPLET_SYSTEM_ARCH}_debug/Chakracore.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)
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

vcpkg_copy_pdbs()
file(INSTALL
    ${SOURCE_PATH}/LICENSE.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/ChakraCore RENAME copyright)
