vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

set(MA_VERSION 904)

vcpkg_download_distfile(ARCHIVE
    URLS "https://monkeysaudio.com/files/MAC_${MA_VERSION}_SDK.zip"
         "https://web.archive.org/web/20210129190227if_/https://monkeysaudio.com/files/MAC_SDK_607.zip"
    FILENAME "MAC_${MA_VERSION}_SDK.zip"
    SHA512 c42c9bae6690a28a69137445c84d53ad7acbd242c2cfe20f329fda46b56812c60de68874301d99cf72ade3bced90fc5aaedacb6fdbca241d4bf4806f6e238219
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
    PATCHES
        fix-project-config.patch
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

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "Source/Projects/VS2019/MACDll/MACDll.vcxproj"
        PLATFORM ${PLATFORM}
    )
else()
    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "Source/Projects/VS2019/MACLib/MACLib.vcxproj"
        PLATFORM ${PLATFORM}
    )
endif()

if ("tools" IN_LIST FEATURES)
    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "Source/Projects/VS2019/Console/Console.vcxproj"
        PLATFORM ${PLATFORM}
    )

    file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/Console.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/Console.lib")
    file(RENAME "${CURRENT_PACKAGES_DIR}/tools/monkeys-audio/Console.exe" "${CURRENT_PACKAGES_DIR}/tools/monkeys-audio/mac.exe")
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/MACLib.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/MACLib.lib")
endif()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(COPY           "${SOURCE_PATH}/Shared/"
     DESTINATION    "${CURRENT_PACKAGES_DIR}/include/monkeys-audio"
     FILES_MATCHING PATTERN "*.h")
file(REMOVE         "${CURRENT_PACKAGES_DIR}/include/monkeys-audio/MACDll.h")

vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/license")
