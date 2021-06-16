vcpkg_fail_port_install(ON_TARGET osx uwp)

if (WIN32)
    vcpkg_fail_port_install(ON_CRT_LINKAGE static ON_LIBRARY_LINKAGE static)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/ChakraCore
    REF 385409ee4b634b860e090606a28acbc99f4d2567
    SHA512 ef47db988c4ddd77fa87f4c5e1ac91d9f6b31b35aa6934d8b2863ee1274776d90a2b85dbad51eef069c96777d3cd7729349b89f23eda8c61b4cb637150bead71
    HEAD_REF master
)

if(WIN32)
    find_path(COR_H_PATH cor.h)
    if(COR_H_PATH MATCHES "NOTFOUND")
        message(FATAL_ERROR "Could not find <cor.h>. Ensure the NETFXSDK is installed.")
    endif()
    get_filename_component(NETFXSDK_PATH "${COR_H_PATH}/../.." ABSOLUTE)
endif()

set(BUILDTREE_PATH ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})
file(REMOVE_RECURSE ${BUILDTREE_PATH})
file(COPY ${SOURCE_PATH}/ DESTINATION ${BUILDTREE_PATH})

set(CHAKRA_RUNTIME_LIB "static_library") # ChakraCore only supports static CRT linkage

if(WIN32)
    vcpkg_build_msbuild(
        PROJECT_PATH ${BUILDTREE_PATH}/Build/Chakra.Core.sln
        OPTIONS
            "/p:DotNetSdkRoot=${NETFXSDK_PATH}/"
            "/p:CustomBeforeMicrosoftCommonTargets=${CMAKE_CURRENT_LIST_DIR}/no-warning-as-error.props"
            "/p:RuntimeLib=${CHAKRA_RUNTIME_LIB}"
    )
else()
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
        set(CHAKRACORE_TARGET_ARCH amd64)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
        set(CHAKRACORE_TARGET_ARCH x86)
    endif()

    vcpkg_find_acquire_program(CLANG)
    if(CLANG MATCHES "-NOTFOUND")
        message(FATAL_ERROR "Clang is required.")
    endif()

    execute_process(
        COMMAND bash "build.sh" "--arch=${CHAKRACORE_TARGET_ARCH}"
        WORKING_DIRECTORY ${BUILDTREE_PATH}
        OUTPUT_VARIABLE CHAKRA_BUILD_SH_OUT
        ERROR_VARIABLE CHAKRA_BUILD_SH_ERR
        RESULT_VARIABLE CHAKRA_BUILD_SH_RES
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
    )
endif()

if (WIN32)
    set(JSRT_DIRECTORY_NAME jsrt)
else()
    set(JSRT_DIRECTORY_NAME Jsrt)
endif()

file(INSTALL
    ${BUILDTREE_PATH}/lib/${JSRT_DIRECTORY_NAME}/ChakraCore.h
    ${BUILDTREE_PATH}/lib/${JSRT_DIRECTORY_NAME}/ChakraCommon.h
    ${BUILDTREE_PATH}/lib/${JSRT_DIRECTORY_NAME}/ChakraDebug.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
if(WIN32)
    file(INSTALL
        ${BUILDTREE_PATH}/lib/${JSRT_DIRECTORY_NAME}/ChakraCommonWindows.h
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
else()

endif()

if(WIN32)
    set(LICENSE_DESTINATION ${CURRENT_PACKAGES_DIR}/share/ChakraCore)
else()
    set(LICENSE_DESTINATION ${CURRENT_PACKAGES_DIR}/share/chakracore)
endif()
file(INSTALL
    ${SOURCE_PATH}/LICENSE.txt
    DESTINATION ${LICENSE_DESTINATION} RENAME copyright)