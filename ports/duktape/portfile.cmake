include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/duktape-2.0.3)
set(CMAKE_PATH ${CMAKE_CURRENT_LIST_DIR})
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/svaarala/duktape/releases/download/v2.0.3/duktape-2.0.3.tar.xz"
    FILENAME "duktape-2.0.3.tar.xz"
    SHA512 ba21731242d953d82c677e1205e3596e270e6d57156a0bca8068fc3b6a35996af69bcfac979b871a7e3eab31f28a06cb99078f0b3eaac54be9c5899f57f4100e
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

# Patch duk_config.h to remove 'undef DUK_F_DLL_BUILD'
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/duk_config.h.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${CMAKE_PATH}
    OPTIONS -DSOURCE_PATH=${SOURCE_PATH}
)

vcpkg_install_cmake()

# Remove debug include
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Copy copright information
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/duktape RENAME copyright)

vcpkg_copy_pdbs()
