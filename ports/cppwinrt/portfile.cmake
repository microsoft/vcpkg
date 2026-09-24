
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.Windows.CppWinRT/${VERSION}"
    FILENAME "cppwinrt.${VERSION}.zip"
    SHA512 6dd1c104365de3a3ead5e3581dcad27be43be2032bb3ed5b21f77e94b1d938849a3297542f22b0f44b1b90541f9822eadd365f912b90a499065fe23c4ba42775
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

vcpkg_check_features(OUT_FEATURE_OPTIONS unused_cppwinrt_options
    FEATURES
        modules     CPPWINRT_MODULES
        fastabi     CPPWINRT_FASTABI
        windowsapp  CPPWINRT_WINDOWSAPP
)

unset(unused_cppwinrt_options)

#--- Create response file
set(args "")
if(CPPWINRT_MODULES)
    string(APPEND args "-modules ")
endif()
if(CPPWINRT_FASTABI)
    string(APPEND args "-fastabi ")
endif()
foreach(winmd IN LISTS winmds)
    string(APPEND args "-input \"${winmd}\"\n")
endforeach()

file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")
file(MAKE_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")
file(WRITE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/cppwinrt.rsp" "${args}")

#--- Generate headers and modules
string(REGEX MATCH "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" SDKVersion $ENV{WindowsSDKVersion})
if(CPPWINRT_MODULES)
    message(STATUS "Generating headers and modules for Windows SDK ${SDKVersion}")
else()
    message(STATUS "Generating headers for Windows SDK ${SDKVersion}")
endif()
vcpkg_execute_required_process(
    COMMAND "${CPPWINRT_TOOL}"
        "@${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/cppwinrt.rsp"
        -output "${CURRENT_PACKAGES_DIR}/include"
        -verbose
    WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}"
    LOGNAME "cppwinrt-generate-${TARGET_TRIPLET}"
)

if(CPPWINRT_FASTABI)
    set(CPPWINRT_LIB "${src}/build/native/lib/${CPPWINRT_ARCH}/cppwinrt_fast_forwarder.lib")
    file(INSTALL "${CPPWINRT_LIB}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    if(NOT DEFINED VCPKG_BUILD_TYPE)
        file(INSTALL "${CPPWINRT_LIB}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif()
endif()

file(INSTALL "${CPPWINRT_TOOL}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/cppwinrt")

set(tool_path "tools/cppwinrt/cppwinrt.exe")
set(lib_name "cppwinrt_fast_forwarder.lib")

configure_file("${CMAKE_CURRENT_LIST_DIR}/cppwinrt-config.cmake.in"
  "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake"
  @ONLY)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${src}/LICENSE")
