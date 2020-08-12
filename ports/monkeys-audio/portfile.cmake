vcpkg_fail_port_install(ON_TARGET "UWP" "OSX" "Linux")

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

set(MA_VERSION 548)

vcpkg_download_distfile(ARCHIVE
    URLS "https://monkeysaudio.com/files/MAC_SDK_${MA_VERSION}.zip"
    FILENAME "MAC_SDK_${MA_VERSION}.zip"
    SHA512 036c75f4cc8dc54837b2f9f822d260ebdbed918dff9ac744746e2786d13a33364d0cd7f380f015e89eaf5ebedd7180df979dfd15cb8f0160e339fafebc93f4ba
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
