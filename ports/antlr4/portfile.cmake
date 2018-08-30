if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

include(vcpkg_common_functions)

set(VERSION 4.7.1)

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.antlr.org/download/antlr4-cpp-runtime-${VERSION}-source.zip"
    FILENAME "antlr4-cpp-runtime-${VERSION}-source.zip"
    SHA512 24d53278db56b199e6787242f22339f74e07d2cd3ed56f851ad905b110c2ba3cb001e1e2fcbc8624f0e93e00ba1fe1b23630dd1a736558c694655aeb1c3129da
)

# license not exist in antlr folder.
vcpkg_download_distfile(LICENSE
    URLS https://raw.githubusercontent.com/antlr/antlr4/${VERSION}/LICENSE.txt
    FILENAME "antlr4-copyright"
    SHA512 c72ae3d5c9f3f07160405b5ca44f01116a9602d82291d6cd218fcc5ec6e8baf985e4baa2acf3d621079585385708bd171c96ef44dd808e60c40a48bc1f56c9ae
)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${VERSION})
vcpkg_extract_source_archive(${ARCHIVE} ${SOURCE_PATH})

vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH}
                    PATCHES ${CMAKE_CURRENT_LIST_DIR}/fixed_build.patch
)

if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL Linux)
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(UUID uuid)
    if (NOT UUID_FOUND)
        message(FATAL_ERROR "Unable to find uuid library. You can execute 'sudo apt-get install uuid-dev'.")
    endif()
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DLIB_OUTPUT_DIR=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/dist
    OPTIONS_RELEASE -DLIB_OUTPUT_DIR=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/dist
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/doc
                    ${CURRENT_PACKAGES_DIR}/debug/share
                    ${CURRENT_PACKAGES_DIR}/debug/include
)

if (NOT VCPKG_CMAKE_SYSTEM_NAME)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/antlr4-runtime-static.lib
                    ${CURRENT_PACKAGES_DIR}/debug/lib/antlr4-runtime-static.lib
        )

        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/antlr4-runtime.dll ${CURRENT_PACKAGES_DIR}/bin/antlr4-runtime.dll)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/antlr4-runtime.dll ${CURRENT_PACKAGES_DIR}/debug/bin/antlr4-runtime.dll)
    else()
        file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/antlr4-runtime.lib
                    ${CURRENT_PACKAGES_DIR}/lib/antlr4-runtime.dll
                    ${CURRENT_PACKAGES_DIR}/debug/lib/antlr4-runtime.lib
                    ${CURRENT_PACKAGES_DIR}/debug/lib/antlr4-runtime.dll
        )

        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/antlr4-runtime-static.lib ${CURRENT_PACKAGES_DIR}/lib/antlr4-runtime.lib)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/antlr4-runtime-static.lib ${CURRENT_PACKAGES_DIR}/debug/lib/antlr4-runtime.lib)
    endif()
else()
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libantlr4-runtime.a
                    ${CURRENT_PACKAGES_DIR}/debug/lib/libantlr4-runtime.a
        )
    elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL Linux)
        file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libantlr4-runtime.so
                    ${CURRENT_PACKAGES_DIR}/lib/libantlr4-runtime.so.${VERSION}
                    ${CURRENT_PACKAGES_DIR}/debug/lib/libantlr4-runtime.so
                    ${CURRENT_PACKAGES_DIR}/debug/lib/libantlr4-runtime.so.${VERSION}
        )
    else()
        file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libantlr4-runtime.dylib
                    ${CURRENT_PACKAGES_DIR}/lib/libantlr4-runtime.${VERSION}.dylib
                    ${CURRENT_PACKAGES_DIR}/debug/lib/libantlr4-runtime.dylib
                    ${CURRENT_PACKAGES_DIR}/debug/lib/libantlr4-runtime.${VERSION}.dylib
        )
    endif()
endif()

vcpkg_copy_pdbs()

file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/antlr4 RENAME copyright)

message(STATUS "Installing done")