include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_STATIC_CRT)

set(VERSION 4.7)

vcpkg_download_distfile(ARCHIVE
    URLS "http://monkeysaudio.com/files/MAC_SDK_483.zip"
    FILENAME "MAC_SDK_483.zip"
    SHA512 c080aa87997def3b970050f6bd334b6908884cc521f192abc02d774a8b3067207781dcab30f052015d4ae891fc6390c6f0b33ed319d9d7fd0850dab6fcded8f0
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

file(REMOVE
    ${SOURCE_PATH}/Shared/MACDll.dll
    ${SOURCE_PATH}/Shared/MACDll.lib
    ${SOURCE_PATH}/Shared/MACLib.lib
)

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH Source/Projects/VS2019/Console/Console.vcxproj
)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
file(COPY           ${SOURCE_PATH}/Shared/
     DESTINATION    ${CURRENT_PACKAGES_DIR}/include/monkeys-audio
     FILES_MATCHING PATTERN "*.h")
file(REMOVE         ${CURRENT_PACKAGES_DIR}/include/monkeys-audio/MACDll.h)

file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/Console.lib ${CURRENT_PACKAGES_DIR}/debug/lib/Console.lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/tools/monkeys-audio/Console.exe ${CURRENT_PACKAGES_DIR}/tools/monkeys-audio/mac.exe)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/license DESTINATION ${CURRENT_PACKAGES_DIR}/share/monkeys-audio RENAME copyright)
