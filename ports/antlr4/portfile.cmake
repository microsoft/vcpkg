if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

include(vcpkg_common_functions)

set(VERSION 4.7.1)

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.antlr.org/download/antlr4-cpp-runtime-4.7.1-source.zip"
    FILENAME "antlr4-cpp-runtime-${VERSION}-source.zip"
    SHA512 24d53278db56b199e6787242f22339f74e07d2cd3ed56f851ad905b110c2ba3cb001e1e2fcbc8624f0e93e00ba1fe1b23630dd1a736558c694655aeb1c3129da
)

# license not exist in antlr folder.
vcpkg_download_distfile(LICENSE
    URLS https://raw.githubusercontent.com/antlr/antlr4/${VERSION}/LICENSE.txt
    FILENAME "antlr4-copyright_${VERSION}"
    SHA512 1e8414de5fdc211e3188a8ec3276c6b3c55235f5edaf48522045ae18fa79fd9049719cb8924d25145016f223ac9a178defada1eeb983ccff598a08b0c0f67a3b
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/crt_mt.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(DEBUG_CONFIG   "Debug Static")
    set(RELEASE_CONFIG "Release Static")
else()
    set(DEBUG_CONFIG   "Debug DLL")
    set(RELEASE_CONFIG "Release DLL")
endif()

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/runtime/antlr4cpp-vs2015.vcxproj
    DEBUG_CONFIGURATION ${DEBUG_CONFIG}
    RELEASE_CONFIGURATION ${RELEASE_CONFIG}
)

file (MAKE_DIRECTORY
    ${CURRENT_PACKAGES_DIR}/include)
FILE(COPY            ${SOURCE_PATH}/runtime/src/
     DESTINATION     ${CURRENT_PACKAGES_DIR}/include
     FILES_MATCHING PATTERN "*.h")

file (MAKE_DIRECTORY
    ${CURRENT_PACKAGES_DIR}/lib
    ${CURRENT_PACKAGES_DIR}/debug/lib)

file(COPY       ${SOURCE_PATH}/runtime/bin/vs-2015/${TRIPLET_SYSTEM_ARCH}/${DEBUG_CONFIG}/antlr4-runtime.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(COPY       ${SOURCE_PATH}/runtime/bin/vs-2015/${TRIPLET_SYSTEM_ARCH}/${RELEASE_CONFIG}/antlr4-runtime.lib
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
        ${SOURCE_PATH}/runtime/bin/vs-2015/${TRIPLET_SYSTEM_ARCH}/${DEBUG_CONFIG}/antlr4-runtime.dll
        ${SOURCE_PATH}/runtime/bin/vs-2015/${TRIPLET_SYSTEM_ARCH}/${DEBUG_CONFIG}/antlr4-runtime.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(COPY
        ${SOURCE_PATH}/runtime/bin/vs-2015/${TRIPLET_SYSTEM_ARCH}/${RELEASE_CONFIG}/antlr4-runtime.dll
        ${SOURCE_PATH}/runtime/bin/vs-2015/${TRIPLET_SYSTEM_ARCH}/${RELEASE_CONFIG}/antlr4-runtime.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
endif()

file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/antlr4 RENAME copyright)

message(STATUS "Installing done")
#