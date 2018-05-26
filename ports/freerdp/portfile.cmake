include(vcpkg_common_functions)

set(FREERDP_VERSION 2.0.0-rc1)
set(FREERDP_REVISION 2.0.0-rc1)
set(FREERDP_HASH 5d8fd7d6900feac1e42bfc0ebc111524205c3baa093958ced42d03635076ae7d88cd86439a22ff0656bc53f0302daee5a114a4ac26328ae598ee086490926182)

string(REGEX REPLACE "\\+" "-" FREERDP_VERSION_ESCAPED ${FREERDP_VERSION})
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/FreeRDP-${FREERDP_VERSION_ESCAPED})


vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FreeRDP/FreeRDP
    REF ${FREERDP_REVISION}
    SHA512 ${FREERDP_HASH}
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/DontInstallSystemRuntimeLibs.patch
            ${CMAKE_CURRENT_LIST_DIR}/FixGitRevisionDetection.patch
)

if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(FREERDP_CRT_LINKAGE -DMSVC_RUNTIME=static)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DGIT_REVISION=${FREERDP_VERSION}
            ${FREERDP_CRT_LINKAGE})

vcpkg_build_cmake()
vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
   file(RENAME "${CURRENT_PACKAGES_DIR}/lib/freerdp-client2.dll" "${CURRENT_PACKAGES_DIR}/bin/freerdp-client2.dll")
   file(RENAME "${CURRENT_PACKAGES_DIR}/lib/freerdp2.dll"        "${CURRENT_PACKAGES_DIR}/bin/freerdp2.dll")
   file(RENAME "${CURRENT_PACKAGES_DIR}/lib/winpr-tools2.dll"    "${CURRENT_PACKAGES_DIR}/bin/winpr-tools2.dll")
   file(RENAME "${CURRENT_PACKAGES_DIR}/lib/winpr2.dll"          "${CURRENT_PACKAGES_DIR}/bin/winpr2.dll")

   file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/freerdp-client2.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/freerdp-client2.dll")
   file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/freerdp2.dll"        "${CURRENT_PACKAGES_DIR}/debug/bin/freerdp2.dll")
   file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/winpr-tools2.dll"    "${CURRENT_PACKAGES_DIR}/debug/bin/winpr-tools2.dll")
   file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/winpr2.dll"          "${CURRENT_PACKAGES_DIR}/debug/bin/winpr2.dll")
endif()

if(NOT TARGET_TRIPLET MATCHES "uwp")
    file(GLOB_RECURSE TOOLS_RELEASE ${CURRENT_PACKAGES_DIR}/bin/*.exe)
    file(GLOB_RECURSE TOOLS_DEBUG ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)

    file(COPY ${TOOLS_RELEASE} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

    file(REMOVE ${TOOLS_RELEASE} ${TOOLS_DEBUG})
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/freerdp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/freerdp/LICENSE ${CURRENT_PACKAGES_DIR}/share/freerdp/copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
endif()

file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/share/freerdp/cmake)
