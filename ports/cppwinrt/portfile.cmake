
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.Windows.CppWinRT/${VERSION}"
    FILENAME "cppwinrt.${VERSION}.zip"
    SHA512 ADF9EC7059A58B3E0EB0057DE52900692F58305AEE8BA708D265D273A81127978BEB9BF2599B00855B61B725D4E6EB06206B66897EAEAEF1AEC83948D60BC293
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
string(REGEX MATCH "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" SDKVersion $ENV{WindowsSDKVersion})
message(STATUS "Generating headers for Windows SDK ${SDKVersion}")
vcpkg_execute_required_process(
    COMMAND "${CPPWINRT_TOOL}"
        "@${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/cppwinrt.rsp"
        -output "${CURRENT_PACKAGES_DIR}/include"
        -verbose
    WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}"
    LOGNAME "cppwinrt-generate-${TARGET_TRIPLET}"
)

set(CPPWINRT_LIB "${src}/build/native/lib/${CPPWINRT_ARCH}/cppwinrt_fast_forwarder.lib")
file(INSTALL "${CPPWINRT_LIB}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
if(NOT DEFINED VCPKG_BUILD_TYPE)
    file(INSTALL "${CPPWINRT_LIB}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()
file(INSTALL "${CPPWINRT_TOOL}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/cppwinrt")

set(tool_path "tools/cppwinrt/cppwinrt.exe")
set(lib_name "cppwinrt_fast_forwarder.lib")

configure_file("${CMAKE_CURRENT_LIST_DIR}/cppwinrt-config.cmake.in"
  "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake"
  @ONLY)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${src}/LICENSE")
