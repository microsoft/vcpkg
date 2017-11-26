include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libzip-1.3.2)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://nih.at/libzip/libzip-1.3.2.tar.gz"
    FILENAME "libzip-1.3.2.tar.gz"
    SHA512 75b7e6f541be30e721275723f264c20f9a3be5335d954b5909acdddb0f6dd9b2420166904c9b88206692a57a4aa54e4fe8ed4d62c1f4b900aebf6ad40f767376
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

# Patch cmake and configuration to allow static builds
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/enable-static.patch"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS -DENABLE_STATIC=OFF
    )
else()
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS -DENABLE_STATIC=ON
    )
endif()

vcpkg_install_cmake()

# Move zipconf.h to include and remove include directories from lib
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libzip/include/zipconf.h ${CURRENT_PACKAGES_DIR}/include/zipconf.h)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/libzip ${CURRENT_PACKAGES_DIR}/debug/lib/libzip)

# Remove debug include
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Copy copright information
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libzip RENAME copyright)

vcpkg_copy_pdbs()
