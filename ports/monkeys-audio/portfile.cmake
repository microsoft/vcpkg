vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

set(MA_VERSION 904)

vcpkg_download_distfile(ARCHIVE
    URLS "https://monkeysaudio.com/files/MAC_${MA_VERSION}_SDK.zip"
    FILENAME "MAC_${MA_VERSION}_SDK.zip"
    SHA512 d104421e9bfa8c36dee89bd292c06629ff39a33e84569a5578f4a255432238a0cf09a7d03c5f7df3daf0e41d5cf3ac88f3b58581daf09a94935de91056334681
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
    PATCHES
        remove-certificate-step.patch
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
    )
    vcpkg_replace_string(
        "${VCXPROJ}"
        "<DebugInformationFormat>EditAndContinue</DebugInformationFormat>"
        "<DebugInformationFormat>OldStyle</DebugInformationFormat>"
    )
endforeach()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "Source/Projects/VS2022/MACDll/MACDll.vcxproj"
        PLATFORM ${PLATFORM}
    )
else()
    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "Source/Projects/VS2022/MACLib/MACLib.vcxproj"
        PLATFORM ${PLATFORM}
    )
endif()

if ("tools" IN_LIST FEATURES)
    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "Source/Projects/VS2022/Console/Console.vcxproj"
        PLATFORM ${PLATFORM}
    )

    file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/Console.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/Console.lib")
    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/monkeys-audio/Console.exe" "${CURRENT_PACKAGES_DIR}/tools/monkeys-audio/mac.exe")
endif()
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    file(COPY "${CURRENT_PACKAGES_DIR}/bin/MACDll.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(COPY "${CURRENT_PACKAGES_DIR}/lib/MACDll.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    file(COPY "${CURRENT_PACKAGES_DIR}/bin/MACDll64.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(COPY "${CURRENT_PACKAGES_DIR}/lib/MACDll64.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()
if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib" "${CURRENT_PACKAGES_DIR}/lib")
endif()


file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(COPY           "${SOURCE_PATH}/Shared/"
     DESTINATION    "${CURRENT_PACKAGES_DIR}/include/monkeys-audio"
     FILES_MATCHING PATTERN "*.h")

vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/license")
