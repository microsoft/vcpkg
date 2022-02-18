set(VERSION 4.9.3)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.antlr.org/download/antlr4-cpp-runtime-${VERSION}-source.zip"
    FILENAME "antlr4-cpp-runtime-${VERSION}-source.zip"
    SHA512 23995a6fa661ff038142fa7220a195db3a9a26744d516011dedc3192f152b06a8e31f6cc8f969f8927b86392a960d03e89572e753f033f950839a5bd38d4c722
)

# license not exist in antlr folder.
vcpkg_download_distfile(LICENSE
    URLS https://raw.githubusercontent.com/antlr/antlr4/${VERSION}/LICENSE.txt
    FILENAME "antlr4-copyright-${VERSION}"
    SHA512 1e8414de5fdc211e3188a8ec3276c6b3c55235f5edaf48522045ae18fa79fd9049719cb8924d25145016f223ac9a178defada1eeb983ccff598a08b0c0f67a3b
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
    REF ${VERSION}
    PATCHES
        fixed_build.patch
        uuid_discovery_fix.patch
        export_guid.patch
        fix_utfcpp_dependency.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_DEBUG -DLIB_OUTPUT_DIR=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/dist
    OPTIONS_RELEASE -DLIB_OUTPUT_DIR=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/dist
)

vcpkg_cmake_install()

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

file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
