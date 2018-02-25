if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()
if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message(FATAL_ERROR "${PORT} currently only support static build")
endif()

include(vcpkg_common_functions)

set(VERSION 4.7)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src)
set(PROJECT_PATH ${SOURCE_PATH}/Source/Projects/VS2017)

vcpkg_download_distfile(ARCHIVE
    URLS "http://monkeysaudio.com/files/MAC_SDK_433.zip"
    FILENAME "MAC_SDK_433.zip"
    SHA512 957ba262da29a8542ab82dc828328b19bf80ecf0d09165db935924b390cb6a3a2d9303a2e07b86b28ecf4210a66dd5c4be840205a9f09518189101033f1a13c8
)

vcpkg_extract_source_archive(${ARCHIVE})

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_apply_patches(
        SOURCE_PATH ${SOURCE_PATH}
        PATCHES ${CMAKE_CURRENT_LIST_DIR}/use-dynamic-linkage.patch
    )
endif()

vcpkg_build_msbuild(
    PROJECT_PATH ${PROJECT_PATH}/Console/Console.vcxproj
)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
file(COPY           ${CURRENT_BUILDTREES_DIR}/src/Shared/
     DESTINATION    ${CURRENT_PACKAGES_DIR}/include/monkeys-audio
     FILES_MATCHING PATTERN "*.h")
file(REMOVE         ${CURRENT_PACKAGES_DIR}/include/monkeys-audio/MACDll.h)

file(COPY
     ${PROJECT_PATH}/MACLib/Debug/MACLib.lib
     ${PROJECT_PATH}/MACLib/Debug/MACLib.pdb
     DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)

file(COPY
     ${PROJECT_PATH}/MACLib/Release/MACLib.lib
     DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)

file(INSTALL ${PROJECT_PATH}/Console/Release/Console.exe
     DESTINATION ${CURRENT_PACKAGES_DIR}/tools/monkeys-audio
     RENAME mac.exe)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/license DESTINATION ${CURRENT_PACKAGES_DIR}/share/monkeys-audio RENAME copyright)
