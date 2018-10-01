include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/tinyutf8-2.1.1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/DuffsDevice/tinyutf8/archive/v2.1.1.zip"
    FILENAME "v2.1.1.zip"
    SHA512 2da2577d35ff64cb383f729a662f05970c32319fbe0092915631f58c38d395133bbabd6da590566f9cced6b02ca15509a7ff6f1ef7f376c8fd5de91446eae74a
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
    ${CMAKE_CURRENT_LIST_DIR}/fixbuild.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=TRUE
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENCE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tinyutf8 RENAME copyright)

# remove unneeded files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()