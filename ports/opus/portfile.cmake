if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "UWP builds not supported")
endif()

include(vcpkg_common_functions)

set(OPUS_VERSION "1.3")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/opus
    REF v1.3
    SHA512 5ac067514b6471432fcd027b912dcaa765e2bdc986ea289a2aeb57660d18fa1460a0a697b9736d8e2b65eb7b72ad4fa36b9b213389fe1e64335db8e9ad51b750
    HEAD_REF master
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/no-main.patch"
)

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/package_version.in
    ${SOURCE_PATH}/package_version
)

# Ensure proper crt linkage
file(READ ${SOURCE_PATH}/win32/VS2015/common.props OPUS_PROPS)
if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    string(REPLACE ">MultiThreaded<" ">MultiThreadedDLL<" OPUS_PROPS "${OPUS_PROPS}")
    string(REPLACE ">MultiThreadedDebug<" ">MultiThreadedDebugDLL<" OPUS_PROPS "${OPUS_PROPS}")
else()
    string(REPLACE ">MultiThreadedDLL<" ">MultiThreaded<" OPUS_PROPS "${OPUS_PROPS}")
    string(REPLACE ">MultiThreadedDebugDLL<" ">MultiThreadedDebug<" OPUS_PROPS "${OPUS_PROPS}")
endif()
file(WRITE ${SOURCE_PATH}/win32/VS2015/common.props "${OPUS_PROPS}")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(RELEASE_CONFIGURATION "Release")
    set(DEBUG_CONFIGURATION "Debug")
else()
    set(RELEASE_CONFIGURATION "ReleaseDll")
    set(DEBUG_CONFIGURATION "DebugDll")
endif()

if(TARGET_TRIPLET MATCHES "x86")
    set(ARCH_DIR "Win32")
elseif(TARGET_TRIPLET MATCHES "x64")
    set(ARCH_DIR "x64")
else()
    message(FATAL_ERROR "Architecture not supported")
endif()

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/win32/VS2015/opus.vcxproj
    RELEASE_CONFIGURATION ${RELEASE_CONFIGURATION}
    DEBUG_CONFIGURATION ${DEBUG_CONFIGURATION}
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    # Install release build
    file(INSTALL ${SOURCE_PATH}/win32/VS2015/${ARCH_DIR}/${RELEASE_CONFIGURATION}/opus.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)

    # Install debug build
    file(INSTALL ${SOURCE_PATH}/win32/VS2015/${ARCH_DIR}/${DEBUG_CONFIGURATION}/opus.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
else()
    # Install release build
    file(INSTALL ${SOURCE_PATH}/win32/VS2015/${ARCH_DIR}/${RELEASE_CONFIGURATION}/opus.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
    file(INSTALL ${SOURCE_PATH}/win32/VS2015/${ARCH_DIR}/${RELEASE_CONFIGURATION}/opus.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin/)

    # Install debug build
    file(INSTALL ${SOURCE_PATH}/win32/VS2015/${ARCH_DIR}/${DEBUG_CONFIGURATION}/opus.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
    file(INSTALL ${SOURCE_PATH}/win32/VS2015/${ARCH_DIR}/${DEBUG_CONFIGURATION}/opus.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin/)
endif()

vcpkg_copy_pdbs()

# Install headers
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR}/include RENAME opus)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(READ ${CURRENT_PACKAGES_DIR}/include/opus/opus_defines.h OPUS_DEFINES)
    string(REPLACE "define OPUS_EXPORT" "define OPUS_EXPORT __declspec(dllimport)" OPUS_DEFINES "${OPUS_DEFINES}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/opus/opus_defines.h "${OPUS_DEFINES}")
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/opus RENAME copyright)
