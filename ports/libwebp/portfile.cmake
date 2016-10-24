include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libwebp-0.5.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/webmproject/libwebp/archive/v0.5.1.zip"
    FILENAME "libwebp-0.5.1.zip"
    SHA512 1d9b218e3b6df50e7bc71b1338619b142a9dcd6cb7cbde2e7a4182b12a353f4f1d830b94dbeb7e6e8aac6e6613ec1aa368ce00a6945cdb7686eb94b287b9fd4e
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/0001-add-install-to-cmake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    # dllexport support seem to be broken
    OPTIONS -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS:BOOL=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_copy_pdbs()
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libwebp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libwebp/COPYING ${CURRENT_PACKAGES_DIR}/share/libwebp/copyright)
