vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

set(MA_VERSION 1008)

vcpkg_download_distfile(ARCHIVE
    URLS "https://monkeysaudio.com/files/MAC_${MA_VERSION}_SDK.zip"
    FILENAME "MAC_${MA_VERSION}_SDK.zip"
    SHA512 0c96b6fa8da9d412679e8c9b43e98d475a650899694a9d085c3b0272775cf229bb09c7c4f24a18ab7ee5516d2d34f7acd59e4216aca8fe08ed04f75e33e29322
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
    PATCHES
        remove-certificate-step.patch
        fix-outdir.patch
)

file(REMOVE_RECURSE
    "${SOURCE_PATH}/Shared/32"
    "${SOURCE_PATH}/Shared/64"
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(PLATFORM Win32)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(PLATFORM x64)
else()
    message(FATAL_ERROR "Unsupported architecture")
endif()

# Use /Z7 rather than /Zi to avoid "fatal error C1090: PDB API call failed, error code '23': (0x00000006)"
foreach(VCXPROJ IN ITEMS
    "${SOURCE_PATH}/Source/Projects/VS2022/Console/Console.vcxproj"
    "${SOURCE_PATH}/Source/Projects/VS2022/DirectShow Filter/APE Decoder.vcxproj"
    "${SOURCE_PATH}/Source/Projects/VS2022/MAC/MAC.vcxproj"
    "${SOURCE_PATH}/Source/Projects/VS2022/MACDll/MACDll.vcxproj"
    "${SOURCE_PATH}/Source/Projects/VS2022/MACLib/MACLib.vcxproj")
    vcpkg_replace_string(
        "${VCXPROJ}"
        "<DebugInformationFormat>ProgramDatabase</DebugInformationFormat>"
        "<DebugInformationFormat>OldStyle</DebugInformationFormat>"
        IGNORE_UNCHANGED
    )
    vcpkg_replace_string(
        "${VCXPROJ}"
        "<DebugInformationFormat>EditAndContinue</DebugInformationFormat>"
        "<DebugInformationFormat>OldStyle</DebugInformationFormat>"
        IGNORE_UNCHANGED
    )
endforeach()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    list(APPEND VCPKG_C_FLAGS "-D_AFXDLL")
    list(APPEND VCPKG_CXX_FLAGS "-D_AFXDLL")
    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "Source/Projects/VS2022/MACDll/MACDll.vcxproj"
        PLATFORM ${PLATFORM}
    )
else()
    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "Source/Projects/VS2022/MACLib/MACLib.vcxproj"
        PLATFORM ${PLATFORM}
    )
endif()

if ("tools" IN_LIST FEATURES)
    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "Source/Projects/VS2022/Console/Console.vcxproj"
        PLATFORM ${PLATFORM}
    )

    file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/Console.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/Console.lib")
    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/monkeys-audio/Console.exe" "${CURRENT_PACKAGES_DIR}/tools/monkeys-audio/mac.exe")
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/MACLib.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/MACLib.lib")
endif()


file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(COPY           "${SOURCE_PATH}/Shared/"
     DESTINATION    "${CURRENT_PACKAGES_DIR}/include/monkeys-audio"
     FILES_MATCHING PATTERN "*.h")

vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/license")
