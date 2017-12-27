include(vcpkg_common_functions)

# NOTE: SoundTouch has a static c++ version too, but entirely different headers, api, etc
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "WindowsStore not supported")
endif()

set(VERSION 2.0.0)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/soundtouch)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.surina.net/soundtouch/soundtouch-${VERSION}.zip"
    FILENAME "soundtouch-${VERSION}.zip"
    SHA512 50ef36b6cd21c16e235b908c5518e29b159b11f658a014c47fe767d3d8acebaefefec0ce253b4ed322cbd26387c69c0ed464ddace0c098e61d56d55c198117a5
)

vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_execute_required_process(
    COMMAND "devenv.exe"
            "SoundTouchDLL.sln"
            /Upgrade
    WORKING_DIRECTORY ${SOURCE_PATH}/source/SoundTouchDLL
    LOGNAME upgrade-Packet-${TARGET_TRIPLET}
)

IF (TRIPLET_SYSTEM_ARCH MATCHES "x64")
    # There is no x64 Debug target
    SET(BUILD_RELEASE_CONFIGURATION "ReleaseX64")
    SET(BUILD_DEBUG_CONFIGURATION "ReleaseX64")
ELSE()
    SET(BUILD_RELEASE_CONFIGURATION "Release")
    SET(BUILD_DEBUG_CONFIGURATION "Debug")
ENDIF()

SET(BUILD_ARCH "Win32")

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/source/SoundTouchDLL/SoundTouchDLL.sln
    PLATFORM ${BUILD_ARCH}
    RELEASE_CONFIGURATION ${BUILD_RELEASE_CONFIGURATION}
    DEBUG_CONFIGURATION ${BUILD_DEBUG_CONFIGURATION}
)

file(INSTALL ${SOURCE_PATH}/source/SoundTouchDLL/SoundTouchDLL.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle libraries
IF (BUILD_RELEASE_CONFIGURATION STREQUAL ReleaseX64)
    file(INSTALL ${SOURCE_PATH}/lib/SoundTouch_x64.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(INSTALL ${SOURCE_PATH}/lib/SoundTouchDll_x64.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
ELSE()
    file(INSTALL ${SOURCE_PATH}/lib/SoundTouch.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(INSTALL ${SOURCE_PATH}/lib/SoundTouchDll.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
ENDIF()

IF (BUILD_DEBUG_CONFIGURATION STREQUAL ReleaseX64)
    file(INSTALL ${SOURCE_PATH}/lib/SoundTouch_x64.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(INSTALL ${SOURCE_PATH}/lib/SoundTouchDll_x64.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
ELSE()
    file(INSTALL ${SOURCE_PATH}/lib/SoundTouchD.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(INSTALL ${SOURCE_PATH}/lib/SoundTouchDllD.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
ENDIF()

file(COPY ${SOURCE_PATH}/COPYING.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/soundtouch)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/soundtouch/COPYING.TXT ${CURRENT_PACKAGES_DIR}/share/soundtouch/copyright)
