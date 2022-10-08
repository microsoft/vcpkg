set(CPPWINRT_VERSION 2.0.220929.3)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.Windows.CppWinRT/${CPPWINRT_VERSION}"
    FILENAME "cppwinrt.${CPPWINRT_VERSION}.zip"
    SHA512 be15d8aab83ee56b4ae45782c87f5e38af6e07c2b468aea157e32b8b5289c1084e955f4d8237f8d9f1ebb4e36564be913b274210f535056fa6d773c8e0cb986b
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH src
    ARCHIVE ${ARCHIVE}
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
