vcpkg_fail_port_install(ON_TARGET "UWP" "OSX" "Linux")

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

set(VERSION 5.14)

vcpkg_download_distfile(ARCHIVE
    URLS "https://monkeysaudio.com/files/MAC_SDK_514.zip"
    FILENAME "MAC_SDK_483.zip"
    SHA512 b0bad044bb639ddf5db6b1234ea07f878f2ed1192f7704c22ed1bc482f3ac7a1abbd318d81114d416ee1d93dccf41ef31d617d6c2b82e819fc2848e01ba4bcd4
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
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
