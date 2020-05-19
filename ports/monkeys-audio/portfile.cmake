vcpkg_fail_port_install(ON_TARGET "UWP" "OSX" "Linux")

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

set(MA_VERSION 538d)

vcpkg_download_distfile(ARCHIVE
    URLS "https://monkeysaudio.com/files/MAC_SDK_${MA_VERSION}.zip"
    FILENAME "MAC_SDK_${MA_VERSION}.zip"
    SHA512 2274d69161fad7740332585792da57e8f82634545da0aa13a5be975434a3df8526d1fd727b3f074ba928e4e252de2e5510e4f6616bb3cf469ef93b65dd55696b
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
    PATCHES fix-project-config.patch
)

file(REMOVE_RECURSE
    ${SOURCE_PATH}/Shared/32
    ${SOURCE_PATH}/Shared/64
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
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH Source/Projects/VS2019/MACDll/MACDll.vcxproj
        PLATFORM ${PLATFORM}
    )
else()
    vcpkg_install_msbuild(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH Source/Projects/VS2019/MACLib/MACLib.vcxproj
        PLATFORM ${PLATFORM}
    )
endif()

if ("tools" IN_LIST FEATURES)
    vcpkg_install_msbuild(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH Source/Projects/VS2019/Console/Console.vcxproj
        PLATFORM ${PLATFORM}
    )
    
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/Console.lib ${CURRENT_PACKAGES_DIR}/debug/lib/Console.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/tools/monkeys-audio/Console.exe ${CURRENT_PACKAGES_DIR}/tools/monkeys-audio/mac.exe)
    
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/MACLib.lib ${CURRENT_PACKAGES_DIR}/debug/lib/MACLib.lib)
endif()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
file(COPY           ${SOURCE_PATH}/Shared/
     DESTINATION    ${CURRENT_PACKAGES_DIR}/include/monkeys-audio
     FILES_MATCHING PATTERN "*.h")
file(REMOVE         ${CURRENT_PACKAGES_DIR}/include/monkeys-audio/MACDll.h)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/license DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)