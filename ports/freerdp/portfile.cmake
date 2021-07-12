vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FreeRDP/FreeRDP
    REF c3df0be63953ed98525d9b736ba878ad733de059 #2.3.2
    SHA512 622d2a1f90f5ef2212dd345a0e51b57a16c69a2972acefdc1cb1d062100ad559932330cca5883e9711a96c032ae56f6f7a084ad48760d763fc38f86cf0fa3bce
    HEAD_REF master
    PATCHES
        DontInstallSystemRuntimeLibs.patch
        fix-linux-build.patch
        openssl_threads.patch
        fix-include-path.patch
        fix-libusb.patch
)

if (NOT VCPKG_TARGET_IS_WINDOWS)
    message(WARNING "${PORT} currently requires the following libraries from the system package manager:\n    libxfixes-dev\n")
endif()
set(FREERDP_WITH_CLIENT)
if (VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_LINUX)
    set(FREERDP_WITH_CLIENT -DWITH_CLIENT=OFF)
endif()

set(FREERDP_CRT_LINKAGE)
if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(FREERDP_CRT_LINKAGE -DMSVC_RUNTIME=static)
endif()

get_filename_component(SOURCE_VERSION "${SOURCE_PATH}" NAME)
file(WRITE "${SOURCE_PATH}/.source_version" "${SOURCE_VERSION}-vcpkg")

file(REMOVE ${SOURCE_PATH}/cmake/FindOpenSSL.cmake) # Remove outdated Module

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    urbdrc CHANNEL_URBDRC
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FREERDP_CRT_LINKAGE}
        ${FREERDP_WITH_CLIENT}
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES wfreerdp winpr-hash winpr-makecert AUTO_CLEAN)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/FreeRDP-Client2 TARGET_PATH share/freerdp-client DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/FreeRDP2 TARGET_PATH share/freerdp DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/WinPR2 TARGET_PATH share/winpr)

# vcpkg's openssl package does not produce libssl.pc and libcrypto.pc
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
