include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_STATIC_CRT)

if(EXISTS ${CURRENT_BUILDTREES_DIR}/src/MAC_SDK_433.zip.extracted)
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/src)
endif()

set(VERSION 4.7)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/433)

vcpkg_download_distfile(ARCHIVE
    URLS "http://monkeysaudio.com/files/MAC_SDK_433.zip"
    FILENAME "MAC_SDK_433.zip"
    SHA512 957ba262da29a8542ab82dc828328b19bf80ecf0d09165db935924b390cb6a3a2d9303a2e07b86b28ecf4210a66dd5c4be840205a9f09518189101033f1a13c8
)

vcpkg_extract_source_archive(${ARCHIVE} ${SOURCE_PATH})

file(REMOVE
    ${SOURCE_PATH}/Shared/MACDll.dll
    ${SOURCE_PATH}/Shared/MACDll.lib
    ${SOURCE_PATH}/Shared/MACLib.lib
)

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH Source/Projects/VS2017/Console/Console.vcxproj
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
