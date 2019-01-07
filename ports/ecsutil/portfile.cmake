include(vcpkg_common_functions)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(PLATFORM x86)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(PLATFORM x64)
else()
    message(FATAL_ERROR "Unsupported architecture")
endif()

if(VCPKG_CMAKE_SYSTEM_NAME)
    message(FATAL_ERROR "Unsupported platform. ECSUTIL currently only supports windows desktop.")
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(ECSUtil_CONFIGURATION_RELEASE Release)
    set(ECSUtil_CONFIGURATION_DEBUG Debug)
else()
    if (VCPKG_CRT_LINKAGE STREQUAL dynamic)
        set(ECSUtil_CONFIGURATION_RELEASE "Release Lib")
        set(ECSUtil_CONFIGURATION_DEBUG "Debug Lib")
    else()
        set(ECSUtil_CONFIGURATION_RELEASE "Release Lib Static")
        set(ECSUtil_CONFIGURATION_DEBUG "Debug Lib Static")
    endif()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO EMCECS/ecs-object-client-windows-cpp
    REF v1.0.2.1
    SHA512 4bb6c223ed562bdb239dc923ea0cfa7b78c1d61c7927017466c08207bffe638ecf3355d581c0a42d8bd966c38420e368b4762fc46a85c14bf071a1136e382451
    HEAD_REF master
    PATCHES NoLibSyms.patch
)

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH ECSUtil.sln
    PLATFORM ${PLATFORM}
    LICENSE_SUBPATH license.txt
    TARGET ECSUtil
    RELEASE_CONFIGURATION ${ECSUtil_CONFIGURATION_RELEASE}
    DEBUG_CONFIGURATION ${ECSUtil_CONFIGURATION_DEBUG}
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(COPY ${SOURCE_PATH}/ECSUtil DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN *.h)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/ECSUtil/res ${CURRENT_PACKAGES_DIR}/tools)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/NatvisAddIn.dll ${CURRENT_PACKAGES_DIR}/debug/bin/NatvisAddIn.dll)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
