include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FreeRDP/FreeRDP
    REF 2.0.0-rc4
    SHA512 b4a4d4a58d09010bc45fb90cca148dc4421a4cf0cd5caf288aa702212ef081f14fc418b91f1b79ec8631f582c9ebcdd3031d3333b6a892adb29c402492abb649
    HEAD_REF master
    PATCHES
        DontInstallSystemRuntimeLibs.patch
)

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(FREERDP_CRT_LINKAGE -DMSVC_RUNTIME=static)
endif()

get_filename_component(SOURCE_VERSION "${SOURCE_PATH}" NAME)
file(WRITE "${SOURCE_PATH}/.source_version" "${SOURCE_VERSION}-vcpkg")

file(REMOVE ${SOURCE_PATH}/cmake/FindOpenSSL.cmake) # Remove outdated Module

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FREERDP_CRT_LINKAGE}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(GLOB_RECURSE TOOLS_RELEASE ${CURRENT_PACKAGES_DIR}/bin/*.exe)

if(TOOLS_RELEASE)
    file(COPY ${TOOLS_RELEASE} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})

    file(GLOB_RECURSE TOOLS_DEBUG ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
    file(REMOVE ${TOOLS_RELEASE} ${TOOLS_DEBUG})
endif()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/freerdp-client2.dll" "${CURRENT_PACKAGES_DIR}/bin/freerdp-client2.dll")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/freerdp2.dll"        "${CURRENT_PACKAGES_DIR}/bin/freerdp2.dll")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/winpr-tools2.dll"    "${CURRENT_PACKAGES_DIR}/bin/winpr-tools2.dll")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/winpr2.dll"          "${CURRENT_PACKAGES_DIR}/bin/winpr2.dll")

    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/freerdp-client2.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/freerdp-client2.dll")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/freerdp2.dll"        "${CURRENT_PACKAGES_DIR}/debug/bin/freerdp2.dll")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/winpr-tools2.dll"    "${CURRENT_PACKAGES_DIR}/debug/bin/winpr-tools2.dll")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/winpr2.dll"          "${CURRENT_PACKAGES_DIR}/debug/bin/winpr2.dll")
else()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

foreach(PACKAGE FreeRDP-Client2 FreeRDP2 WinPR2)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib/cmake/${PACKAGE}_temp)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/${PACKAGE} ${CURRENT_PACKAGES_DIR}/lib/cmake/${PACKAGE}_temp/${PACKAGE})
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/${PACKAGE}_temp)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/${PACKAGE} ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/${PACKAGE}_temp/${PACKAGE})
endforeach()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/FreeRDP-Client2_temp/FreeRDP-Client2 TARGET_PATH share/freerdp-client)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/FreeRDP2_temp/FreeRDP2)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/WinPR2_temp/WinPR2 TARGET_PATH share/winpr)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/freerdp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/freerdp/LICENSE ${CURRENT_PACKAGES_DIR}/share/freerdp/copyright)
