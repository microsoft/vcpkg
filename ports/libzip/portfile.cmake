include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libzip-1.2.0)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://nih.at/libzip/libzip-1.2.0.tar.gz"
    FILENAME "libzip-1.2.0.tar.gz"
    SHA512 b71642a80f8e2573c9082d513018bfd2d1d155663ac83fdf7ec969a08d5230fcbc76f2cf89c26ff1d1288e9f407ba9fa234604d813ed3bab816ca1670f7a53f3
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

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/zipstatic.lib ${CURRENT_PACKAGES_DIR}/lib/zip.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/zipstatic.lib ${CURRENT_PACKAGES_DIR}/debug/lib/zip.lib)
endif()

# Move zipconf.h to include and remove include directories from lib
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libzip/include/zipconf.h ${CURRENT_PACKAGES_DIR}/include/zipconf.h)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/libzip ${CURRENT_PACKAGES_DIR}/debug/lib/libzip)

# Remove debug include
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Copy copright information
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libzip RENAME copyright)

vcpkg_copy_pdbs()
