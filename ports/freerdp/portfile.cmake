include(vcpkg_common_functions)

set(FREERDP_VERSION 2.0.0-rc0)
set(FREERDP_REVISION 2.0.0-rc0)
set(FREERDP_HASH 9bc9ee976c73f274a4258613409e242088bd077bcd1cc43f7941170374fc0f9deda7f2f7644506d0cdc2e029b6037abb21d848810dcce6aefa3c5f1642f19cb3)

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
    make_directory("${CURRENT_PACKAGES_DIR}/tools")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/winpr-hash.exe"     "${CURRENT_PACKAGES_DIR}/tools/winpr-hash.exe")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/winpr-makecert.exe" "${CURRENT_PACKAGES_DIR}/tools/winpr-makecert.exe")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/wfreerdp.exe"       "${CURRENT_PACKAGES_DIR}/tools/wfreerdp.exe")

    make_directory("${CURRENT_PACKAGES_DIR}/debug/tools")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/winpr-hash.exe"     "${CURRENT_PACKAGES_DIR}/debug/tools/winpr-hash.exe")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/winpr-makecert.exe" "${CURRENT_PACKAGES_DIR}/debug/tools/winpr-makecert.exe")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/wfreerdp.exe"       "${CURRENT_PACKAGES_DIR}/debug/tools/wfreerdp.exe")
endif()

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