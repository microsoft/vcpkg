# UWP Not Support
if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "Error: UWP builds are currently not supported.")
endif()

# Static Build Not Support
if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message(STATUS "Warning: Static building not supported. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE "dynamic")
endif()

# Static CRT linkage not supported
if (VCPKG_CRT_LINKAGE STREQUAL "static")
    message(STATUS "Warning: Static CRT linkage is not supported. Building dynamic.")
    set(VCPKG_CRT_LINKAGE "dynamic")
endif()

# Download Source Code
include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenNI/OpenNI2
    REF 2.2-beta2
    SHA512 60a3a3043679f3069aea869e92dc5881328ce4393d4140ea8d089027321ac501ae27d283657214e2834d216d0d49bf4f29a4b3d3e43df27a6ed21f889cd0083f
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/upgrade_projects.patch"
            "${CMAKE_CURRENT_LIST_DIR}/inherit_from_parent_or_project_defaults.patch"
            "${CMAKE_CURRENT_LIST_DIR}/replace_environment_variable.patch"
)

file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})
file(COPY ${SOURCE_PATH} DESTINATION ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})
get_filename_component(SOURCE_DIR_NAME "${SOURCE_PATH}" NAME)

# Use fresh copy of sources for building and modification
set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/${SOURCE_DIR_NAME}")

file(TO_NATIVE_PATH ${CURRENT_INSTALLED_DIR} NATIVE_INSTALLED_DIR)
configure_file("${SOURCE_PATH}/Source/Drivers/Kinect/Kinect.vcxproj" "${SOURCE_PATH}/Source/Drivers/Kinect/Kinect.vcxproj" @ONLY)

# Build OpenNI2
vcpkg_build_msbuild(
    PROJECT_PATH "${SOURCE_PATH}/OpenNI.sln"
)

# Install OpenNI2
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(PLATFORM Win32)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(PLATFORM x64)
endif()

set(SOURCE_INCLUDE_PATH "${SOURCE_PATH}/Include")
set(SOURCE_BIN_PATH_RELEASE "${SOURCE_PATH}/Bin/${PLATFORM}-Release")
set(SOURCE_BIN_PATH_DEBUG "${SOURCE_PATH}/Bin/${PLATFORM}-Debug")
set(SOURCE_CONFIG_PATH "${SOURCE_PATH}/Config")
set(SOURCE_THIRDPARTY_PATH "${SOURCE_PATH}/ThirdParty")

file(
    INSTALL
        "${SOURCE_INCLUDE_PATH}/Android-Arm/OniPlatformAndroid-Arm.h"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/include/openni2/Android-Arm
)

file(
    INSTALL
        "${SOURCE_INCLUDE_PATH}/Driver/OniDriverAPI.h"
        "${SOURCE_INCLUDE_PATH}/Driver/OniDriverTypes.h"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/include/openni2/Driver
)

file(
    INSTALL
        "${SOURCE_INCLUDE_PATH}/Linux-Arm/OniPlatformLinux-Arm.h"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/include/openni2/Linux-Arm
)

file(
    INSTALL
        "${SOURCE_INCLUDE_PATH}/Linux-x86/OniPlatformLinux-x86.h"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/include/openni2/Linux-x86
)

file(
    INSTALL
        "${SOURCE_INCLUDE_PATH}/MacOSX/OniPlatformMacOSX.h"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/include/openni2/MacOSX
)

file(
    INSTALL
        "${SOURCE_INCLUDE_PATH}/Win32/OniPlatformWin32.h"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/include/openni2/Win32
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
        ${CURRENT_PACKAGES_DIR}/include/openni2
)

file(
    INSTALL
        "${SOURCE_BIN_PATH_RELEASE}/OpenNI2.lib"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/lib
)

file(
    INSTALL
        "${SOURCE_BIN_PATH_DEBUG}/OpenNI2.lib"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/debug/lib
)

file(
    INSTALL
        "${SOURCE_BIN_PATH_RELEASE}/OpenNI2/Drivers/Kinect.dll"
        "${SOURCE_BIN_PATH_RELEASE}/OpenNI2/Drivers/OniFile.dll"
        "${SOURCE_BIN_PATH_RELEASE}/OpenNI2/Drivers/PS1080.dll"
        "${SOURCE_CONFIG_PATH}/OpenNI2/Drivers/PS1080.ini"
        "${SOURCE_BIN_PATH_RELEASE}/OpenNI2/Drivers/PSLink.dll"
        "${SOURCE_CONFIG_PATH}/OpenNI2/Drivers/PSLink.ini"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/bin/OpenNI2/Drivers
)

file(
    INSTALL
        "${SOURCE_CONFIG_PATH}/OpenNI.ini"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/bin/OpenNI2
)

file(
    INSTALL
        "${SOURCE_BIN_PATH_RELEASE}/OpenNI2.dll"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/bin
)

file(
    INSTALL
        "${SOURCE_BIN_PATH_DEBUG}/OpenNI2/Drivers/Kinect.dll"
        "${SOURCE_BIN_PATH_DEBUG}/OpenNI2/Drivers/OniFile.dll"
        "${SOURCE_BIN_PATH_DEBUG}/OpenNI2/Drivers/PS1080.dll"
        "${SOURCE_CONFIG_PATH}/OpenNI2/Drivers/PS1080.ini"
        "${SOURCE_BIN_PATH_DEBUG}/OpenNI2/Drivers/PSLink.dll"
        "${SOURCE_CONFIG_PATH}/OpenNI2/Drivers/PSLink.ini"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/debug/bin/OpenNI2/Drivers
)

file(
    INSTALL
        "${SOURCE_CONFIG_PATH}/OpenNI.ini"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/debug/bin/OpenNI2
)

file(
    INSTALL
        "${SOURCE_BIN_PATH_DEBUG}/OpenNI2.dll"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/debug/bin
)

file(
    INSTALL
        "${SOURCE_BIN_PATH_RELEASE}/OpenNI2/Drivers/Kinect.dll"
        "${SOURCE_BIN_PATH_RELEASE}/OpenNI2/Drivers/OniFile.dll"
        "${SOURCE_BIN_PATH_RELEASE}/OpenNI2/Drivers/PS1080.dll"
        "${SOURCE_CONFIG_PATH}/OpenNI2/Drivers/PS1080.ini"
        "${SOURCE_BIN_PATH_RELEASE}/OpenNI2/Drivers/PSLink.dll"
        "${SOURCE_CONFIG_PATH}/OpenNI2/Drivers/PSLink.ini"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/tools/openni2/OpenNI2/Drivers
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
        ${CURRENT_PACKAGES_DIR}/tools/openni2
)

# Deploy Script
file(COPY ${CMAKE_CURRENT_LIST_DIR}/openni2deploy.ps1 DESTINATION ${CURRENT_PACKAGES_DIR}/bin/OpenNI2)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/openni2deploy.ps1 DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin/OpenNI2)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openni2)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/openni2/LICENSE ${CURRENT_PACKAGES_DIR}/share/openni2/copyright)