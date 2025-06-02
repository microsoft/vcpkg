vcpkg_download_distfile(
    ARCHIVE
    URLS https://github.com/svaarala/duktape/releases/download/v2.7.0/duktape-2.7.0.tar.xz
    FILENAME duktape-2.7.0.tar.xz
    SHA512 8ff5465c9c335ea08ebb0d4a06569c991b9dc4661b63e10da6b123b882e7375e82291d6b883c2644902d68071a29ccc880dae8229447cebe710c910b54496c1d
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${SOURCE_PATH}/src/duk_config.h" "#undef DUK_F_DLL_BUILD" "#define DUK_F_DLL_BUILD")
else()
    vcpkg_replace_string("${SOURCE_PATH}/src/duk_config.h" "#define DUK_F_DLL_BUILD" "#undef DUK_F_DLL_BUILD" IGNORE_UNCHANGED)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DVERSION=${VERSION}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-duktape)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Legacy package based on find commands, not on exported config.
file(COPY "${CURRENT_PORT_DIR}/duktapeConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
