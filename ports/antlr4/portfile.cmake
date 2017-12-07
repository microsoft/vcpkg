if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

include(vcpkg_common_functions)

set(VERSION 4.7)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/runtime)

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.antlr.org/download/antlr4-cpp-runtime-4.7-source.zip"
    FILENAME "antlr4-cpp-runtime-${VERSION}-source.zip"
    SHA512 a14fd3320537075a8d4c1cfa81d416bad6257d238608e2428f4930495072cce984c707126e3777ffd3849dd6b6cdf1bf43624bd6d318b1fa5dd6749a7304f808
)

# license not exist in antlr folder.
vcpkg_download_distfile(LICENSE
    URLS https://raw.githubusercontent.com/antlr/antlr4/${VERSION}/LICENSE.txt
    FILENAME "antlr4-copyright"
    SHA512 c72ae3d5c9f3f07160405b5ca44f01116a9602d82291d6cd218fcc5ec6e8baf985e4baa2acf3d621079585385708bd171c96ef44dd808e60c40a48bc1f56c9ae
)

vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src
    PATCHES     ${CMAKE_CURRENT_LIST_DIR}/crt_mt.patch
                ${CMAKE_CURRENT_LIST_DIR}/Fix-building-in-Visual-Studio-2017.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(DEBUG_CONFIG   "Debug Static")
    set(RELEASE_CONFIG "Release Static")
else()
    set(DEBUG_CONFIG   "Debug DLL")
    set(RELEASE_CONFIG "Release DLL")
endif()

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/antlr4cpp-vs2015.vcxproj
    DEBUG_CONFIGURATION ${DEBUG_CONFIG}
    RELEASE_CONFIGURATION ${RELEASE_CONFIG}
)

file (MAKE_DIRECTORY
    ${CURRENT_PACKAGES_DIR}/include)
FILE(COPY            ${SOURCE_PATH}/src/
     DESTINATION     ${CURRENT_PACKAGES_DIR}/include
     FILES_MATCHING PATTERN "*.h")

file (MAKE_DIRECTORY
    ${CURRENT_PACKAGES_DIR}/lib
    ${CURRENT_PACKAGES_DIR}/debug/lib)

file(COPY       ${SOURCE_PATH}/bin/vs-2015/${TRIPLET_SYSTEM_ARCH}/${DEBUG_CONFIG}/antlr4-runtime.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(COPY       ${SOURCE_PATH}/bin/vs-2015/${TRIPLET_SYSTEM_ARCH}/${RELEASE_CONFIG}/antlr4-runtime.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_apply_patches(
        SOURCE_PATH ${CURRENT_PACKAGES_DIR}/include
        PATCHES     ${CMAKE_CURRENT_LIST_DIR}/static.patch
    )
else()
    file (MAKE_DIRECTORY
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/debug/bin)

    file(COPY
        ${SOURCE_PATH}/bin/vs-2015/${TRIPLET_SYSTEM_ARCH}/${DEBUG_CONFIG}/antlr4-runtime.dll
        ${SOURCE_PATH}/bin/vs-2015/${TRIPLET_SYSTEM_ARCH}/${DEBUG_CONFIG}/antlr4-runtime.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(COPY
        ${SOURCE_PATH}/bin/vs-2015/${TRIPLET_SYSTEM_ARCH}/${RELEASE_CONFIG}/antlr4-runtime.dll
        ${SOURCE_PATH}/bin/vs-2015/${TRIPLET_SYSTEM_ARCH}/${RELEASE_CONFIG}/antlr4-runtime.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
endif()

file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/antlr4 RENAME copyright)

message(STATUS "Installing done")