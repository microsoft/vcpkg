vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.Windows.CppWinRT/${VERSION}"
    FILENAME "cppwinrt.${VERSION}.zip"
    SHA512 0a5a46bf2508ee396861b810a2196e694f351385700c267cb6637dcbb966a4017703020378289aebb50c508cf082c9be9b7f4c756fd757d177ebd74480b7d13e
)

vcpkg_extract_source_archive(
    src
    ARCHIVE "${ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(CPPWINRT_ARCH win32)
else()
    set(CPPWINRT_ARCH ${VCPKG_TARGET_ARCHITECTURE})
endif()

set(CPPWINRT_TOOL "${src}/bin/cppwinrt.exe")

#--- Find Windows SDK Version
if (NOT EXISTS "$ENV{WindowsSDKDir}/Lib/$ENV{WindowsSDKVersion}.")
    message(FATAL_ERROR "ERROR: Cannot locate the Windows SDK. Please define %WindowsSDKDir% and %WindowsSDKVersion%.
(Expected file to exist: $ENV{WindowsSDKDir}/Lib/$ENV{WindowsSDKVersion})")
endif()
if (NOT EXISTS "$ENV{WindowsSDKDir}References/$ENV{WindowsSDKVersion}Windows.Foundation.FoundationContract")
    message(FATAL_ERROR "ERROR: The Windows SDK is too old (needs 14393 or later, found $ENV{WindowsSDKVersion}).")
endif()

file(TO_CMAKE_PATH "$ENV{WindowsSDKDir}References/$ENV{WindowsSDKVersion}" winsdk)

file(GLOB winmds "${winsdk}/*/*/*.winmd")

#--- Create response file
set(args "")
foreach(winmd IN LISTS winmds)
    string(APPEND args "-input \"${winmd}\"\n")
endforeach()

file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")
file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")
file(WRITE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/cppwinrt.rsp" "${args}")

#--- Generate headers
message(STATUS "Generating headers for Windows SDK $ENV{WindowsSDKVersion}")
vcpkg_execute_required_process(
    COMMAND "${CPPWINRT_TOOL}"
        "@${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/cppwinrt.rsp"
        -output "${CURRENT_PACKAGES_DIR}/include"
        -verbose
    WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}"
    LOGNAME "cppwinrt-generate-${TARGET_TRIPLET}"
)

set(CPPWINRT_LIB "${src}/build/native/lib/${CPPWINRT_ARCH}/cppwinrt_fast_forwarder.lib")
file(COPY "${CPPWINRT_LIB}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
if(NOT VCPKG_BUILD_TYPE)
    file(COPY "${CPPWINRT_LIB}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()
file(COPY
    "${CPPWINRT_TOOL}"
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/cppwinrt")
file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/cppwinrt-config.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/cppwinrt")

configure_file("${src}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
