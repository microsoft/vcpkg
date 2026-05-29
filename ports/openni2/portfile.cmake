find_path(COR_H_PATH cor.h)
if(COR_H_PATH MATCHES "NOTFOUND")
    message(FATAL_ERROR "Could not find <cor.h>. Ensure the NETFXSDK is installed.")
endif()
get_filename_component(NETFXSDK_PATH "${COR_H_PATH}/../.." ABSOLUTE)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenNI/OpenNI2
    REF 2.2-beta2
    SHA512 60a3a3043679f3069aea869e92dc5881328ce4393d4140ea8d089027321ac501ae27d283657214e2834d216d0d49bf4f29a4b3d3e43df27a6ed21f889cd0083f
    HEAD_REF master
    PATCHES upgrade_projects.patch
            inherit_from_parent_or_project_defaults.patch
            replace_environment_variable.patch
)

file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}" NATIVE_INSTALLED_DIR)
configure_file("${SOURCE_PATH}/Source/Drivers/Kinect/Kinect.vcxproj" "${SOURCE_PATH}/Source/Drivers/Kinect/Kinect.vcxproj" @ONLY)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(additional_options PLATFORM "x86")
endif()

# Build OpenNI2
vcpkg_msbuild_install(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH OpenNI.sln
    OPTIONS "/p:DotNetSdkRoot=${NETFXSDK_PATH}/"
    NO_TOOLCHAIN_PROPS # Port uses /clr which conflicts with /EHs(a) from the toolchain
    NO_INSTALL # Port seems to have its own layout regarding bin/lib
    ${additional_options}
)

# Install OpenNI2
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(PLATFORM Win32)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(PLATFORM x64)
endif()

set(SOURCE_INCLUDE_PATH "${SOURCE_PATH}/Include")
set(SOURCE_BIN_PATH_RELEASE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Bin/${PLATFORM}-Release")
set(SOURCE_BIN_PATH_DEBUG "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Bin/${PLATFORM}-Debug")
set(SOURCE_CONFIG_PATH "${SOURCE_PATH}/Config")
set(SOURCE_THIRDPARTY_PATH "${SOURCE_PATH}/ThirdParty")

file(
    INSTALL
        "${SOURCE_INCLUDE_PATH}/Android-Arm/OniPlatformAndroid-Arm.h"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/include/openni2/Android-Arm"
)

file(
    INSTALL
        "${SOURCE_INCLUDE_PATH}/Driver/OniDriverAPI.h"
        "${SOURCE_INCLUDE_PATH}/Driver/OniDriverTypes.h"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/include/openni2/Driver"
)

file(
    INSTALL
        "${SOURCE_INCLUDE_PATH}/Linux-Arm/OniPlatformLinux-Arm.h"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/include/openni2/Linux-Arm"
)

file(
    INSTALL
        "${SOURCE_INCLUDE_PATH}/Linux-x86/OniPlatformLinux-x86.h"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/include/openni2/Linux-x86"
)

file(
    INSTALL
        "${SOURCE_INCLUDE_PATH}/MacOSX/OniPlatformMacOSX.h"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/include/openni2/MacOSX"
)

file(
    INSTALL
        "${SOURCE_INCLUDE_PATH}/Win32/OniPlatformWin32.h"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/include/openni2/Win32"
)

file(
    INSTALL
        "${SOURCE_INCLUDE_PATH}/OniCAPI.h"
        "${SOURCE_INCLUDE_PATH}/OniCEnums.h"
        "${SOURCE_INCLUDE_PATH}/OniCProperties.h"
        "${SOURCE_INCLUDE_PATH}/OniCTypes.h"
        "${SOURCE_INCLUDE_PATH}/OniEnums.h"
        "${SOURCE_INCLUDE_PATH}/OniPlatform.h"
        "${SOURCE_INCLUDE_PATH}/OniProperties.h"
        "${SOURCE_INCLUDE_PATH}/OniVersion.h"
        "${SOURCE_INCLUDE_PATH}/OpenNI.h"
        "${SOURCE_INCLUDE_PATH}/PrimeSense.h"
        "${SOURCE_INCLUDE_PATH}/PS1080.h"
        "${SOURCE_INCLUDE_PATH}/PSLink.h"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/include/openni2"
)

file(
    INSTALL
        "${SOURCE_BIN_PATH_RELEASE}/OpenNI2.lib"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/lib"
)

if(NOT VCPKG_BUILD_TYPE)
file(
    INSTALL
        "${SOURCE_BIN_PATH_DEBUG}/OpenNI2.lib"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/debug/lib"
)
endif()

file(
    INSTALL
        "${SOURCE_BIN_PATH_RELEASE}/OpenNI2/Drivers/Kinect.dll"
        "${SOURCE_BIN_PATH_RELEASE}/OpenNI2/Drivers/OniFile.dll"
        "${SOURCE_BIN_PATH_RELEASE}/OpenNI2/Drivers/PS1080.dll"
        "${SOURCE_CONFIG_PATH}/OpenNI2/Drivers/PS1080.ini"
        "${SOURCE_BIN_PATH_RELEASE}/OpenNI2/Drivers/PSLink.dll"
        "${SOURCE_CONFIG_PATH}/OpenNI2/Drivers/PSLink.ini"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/bin/OpenNI2/Drivers"
)

file(
    INSTALL
        "${SOURCE_CONFIG_PATH}/OpenNI.ini"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/bin/OpenNI2"
)

file(
    INSTALL
        "${SOURCE_BIN_PATH_RELEASE}/OpenNI2.dll"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/bin"
)

if(NOT VCPKG_BUILD_TYPE)
file(
    INSTALL
        "${SOURCE_BIN_PATH_DEBUG}/OpenNI2/Drivers/Kinect.dll"
        "${SOURCE_BIN_PATH_DEBUG}/OpenNI2/Drivers/OniFile.dll"
        "${SOURCE_BIN_PATH_DEBUG}/OpenNI2/Drivers/PS1080.dll"
        "${SOURCE_CONFIG_PATH}/OpenNI2/Drivers/PS1080.ini"
        "${SOURCE_BIN_PATH_DEBUG}/OpenNI2/Drivers/PSLink.dll"
        "${SOURCE_CONFIG_PATH}/OpenNI2/Drivers/PSLink.ini"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/debug/bin/OpenNI2/Drivers"
)
endif()

file(
    INSTALL
        "${SOURCE_CONFIG_PATH}/OpenNI.ini"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/debug/bin/OpenNI2"
)

if(NOT VCPKG_BUILD_TYPE)
file(
    INSTALL
        "${SOURCE_BIN_PATH_DEBUG}/OpenNI2.dll"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/debug/bin"
)
endif()

file(
    INSTALL
        "${SOURCE_BIN_PATH_RELEASE}/OpenNI2/Drivers/Kinect.dll"
        "${SOURCE_BIN_PATH_RELEASE}/OpenNI2/Drivers/OniFile.dll"
        "${SOURCE_BIN_PATH_RELEASE}/OpenNI2/Drivers/PS1080.dll"
        "${SOURCE_CONFIG_PATH}/OpenNI2/Drivers/PS1080.ini"
        "${SOURCE_BIN_PATH_RELEASE}/OpenNI2/Drivers/PSLink.dll"
        "${SOURCE_CONFIG_PATH}/OpenNI2/Drivers/PSLink.ini"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/tools/openni2/OpenNI2/Drivers"
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(NUMBEROFBIT 32)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(NUMBEROFBIT 64)
endif()

file(
    INSTALL
        "${SOURCE_THIRDPARTY_PATH}/GL/glut${NUMBEROFBIT}.dll"
        "${SOURCE_BIN_PATH_RELEASE}/NiViewer.exe"
        "${SOURCE_CONFIG_PATH}/OpenNI.ini"
        "${SOURCE_BIN_PATH_RELEASE}/OpenNI2.dll"
        "${SOURCE_BIN_PATH_RELEASE}/PS1080Console.exe"
        "${SOURCE_BIN_PATH_RELEASE}/PSLinkConsole.exe"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/tools/openni2"
)

# Deploy Script
file(COPY "${CMAKE_CURRENT_LIST_DIR}/openni2deploy.ps1" DESTINATION "${CURRENT_PACKAGES_DIR}/bin/OpenNI2")
if(NOT VCPKG_BUILD_TYPE)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/openni2deploy.ps1" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin/OpenNI2")
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
