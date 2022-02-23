if(VCPKG_CMAKE_SYSTEM_NAME)
    message(FATAL_ERROR "getopt-win32 only supports building on Windows Desktop")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/getopt
    REF 0.1
    SHA512 40e2a901241a5d751cec741e5de423c8f19b105572c7cae18adb6e69be0b408efc6c9a2ecaeb62f117745eac0d093f30d6b91d88c1a27e1f7be91f0e84fdf199
    HEAD_REF master
    PATCHES getopt.h.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    list(APPEND OPTIONS "/p:ConfigurationType=StaticLibrary")
else()
    list(APPEND OPTIONS "/p:ConfigurationType=DynamicLibrary")
endif()

set(_file "${SOURCE_PATH}/getopt.vcxproj")
file(READ "${_file}" _contents)
if(VCPKG_CRT_LINKAGE STREQUAL static)
    string(REPLACE "<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>" "<RuntimeLibrary>MultiThreaded</RuntimeLibrary>" _contents "${_contents}")
    string(REPLACE "<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>" "<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>" _contents "${_contents}")
else()
    string(REPLACE "<RuntimeLibrary>MultiThreaded</RuntimeLibrary>" "<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>" _contents "${_contents}")
    string(REPLACE "<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>"  "<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>" _contents "${_contents}")
endif()
file(WRITE "${_file}" "${_contents}")



vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH getopt.vcxproj
    LICENSE_SUBPATH LICENSE
    OPTIONS ${OPTIONS}
)

# Copy header
file(COPY "${SOURCE_PATH}/getopt.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/")
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/getopt.h"
        "	#define __GETOPT_H_" "	#define __GETOPT_H_\n	#define STATIC_GETOPT"
    )
endif()

set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)
