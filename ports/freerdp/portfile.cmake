vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FreeRDP/FreeRDP
    REF 2.0.0
    SHA512 efdaa1b018e5166c0f2469663bdd0dc788de0577d0c0cb8b98048a535f8cb07de1078f86aaacc9445d42078d2e02fd7bc7f1ed700ca96032976f6bd84c68ee8f
    HEAD_REF master
    PATCHES
        DontInstallSystemRuntimeLibs.patch
        fix-linux-build.patch
        openssl_threads.patch
        fix-include-install-path.patch
        fix-include-path.patch
        fix-libusb.patch
)

if (NOT VCPKG_TARGET_IS_WINDOWS)
    message(WARNING "${PORT} currently requires the following libraries from the system package manager:\n    libxfixes-dev\n")
endif()

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
    file(GLOB_RECURSE FREERDP_DLLS "${CURRENT_PACKAGES_DIR}/lib/*.dll")
    foreach(FREERDP_DLL ${FREERDP_DLLS})
        file(COPY ${FREERDP_DLL} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
        file(REMOVE ${FREERDP_DLL})
    endforeach()
    
    file(GLOB_RECURSE FREERDP_DLLS "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll")
    foreach(FREERDP_DLL ${FREERDP_DLLS})
        file(COPY ${FREERDP_DLL} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
        file(REMOVE ${FREERDP_DLL})
    endforeach()
else()    
    file(GLOB_RECURSE FREERDP_TOOLS "${CURRENT_PACKAGES_DIR}/bin/*")
    foreach(FREERDP_TOOL ${FREERDP_TOOLS})
        file(COPY ${FREERDP_TOOL} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
        file(REMOVE ${FREERDP_TOOL})
    endforeach()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

foreach(PACKAGE FreeRDP-Client2 FreeRDP2 WinPR2)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib/cmake/${PACKAGE}_temp)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/${PACKAGE} ${CURRENT_PACKAGES_DIR}/lib/cmake/${PACKAGE}_temp/${PACKAGE})
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/${PACKAGE}_temp)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/${PACKAGE} ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/${PACKAGE}_temp/${PACKAGE})
endforeach()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/FreeRDP-Client2_temp/FreeRDP-Client2 TARGET_PATH share/FreeRDP-Client)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/FreeRDP2_temp/FreeRDP2 TARGET_PATH share/FreeRDP)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/WinPR2_temp/WinPR2 TARGET_PATH share/WinPR)

vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/WinPR/WinPRTargets-debug.cmake
    "debug/lib/winpr2${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}"
    "debug/bin/winpr2${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}"
)
vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/WinPR/WinPRTargets-debug.cmake
    "debug/lib/winpr-tools2${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}"
    "debug/bin/winpr-tools2${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}"
)
vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/WinPR/WinPRTargets-release.cmake
    "lib/winpr2${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}"
    "bin/winpr2${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}"
)
vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/WinPR/WinPRTargets-release.cmake
    "lib/winpr-tools2${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}"
    "bin/winpr-tools2${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}"
)
vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/FreeRDP/FreeRDPTargets-debug.cmake
    "debug/lib/freerdp2${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}"
    "debug/bin/freerdp2${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}"
)
vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/FreeRDP/FreeRDPTargets-release.cmake
    "lib/freerdp2${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}"
    "bin/freerdp2${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}"
)
vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/FreeRDP-Client/FreeRDP-ClientTargets-debug.cmake
    "debug/lib/freerdp-client2${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}"
    "debug/bin/freerdp-client2${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}"
)
vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/FreeRDP-Client/FreeRDP-ClientTargets-release.cmake
    "lib/freerdp-client2${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}"
    "bin/freerdp-client2${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(GLOB OBJS ${CURRENT_PACKAGES_DIR}/debug/*.lib)
    file(REMOVE ${OBJS})
    file(GLOB OBJS ${CURRENT_PACKAGES_DIR}/*.lib)
    file(REMOVE ${OBJS})
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/debug/share
                    ${CURRENT_PACKAGES_DIR}/debug/lib/cmake
                    ${CURRENT_PACKAGES_DIR}/lib/cmake)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)