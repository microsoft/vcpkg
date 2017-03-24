include(vcpkg_common_functions)

set(WEBP_VERSION 0.6.0)
set(WEBP_HASH 59491b3837c7c96e56407c479722ad48b08b6133b123b61f66c5f0b61a1e8222ed20006b5c6fc708791bed72ac65e707aa25635e07fd11c81f26cc1e23892f48)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libwebp-${WEBP_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/webmproject/libwebp/archive/v${WEBP_VERSION}.zip"
    FILENAME "libwebp-${WEBP_VERSION}.zip"
    SHA512 ${WEBP_HASH}
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/0001-add-install-to-cmake.patch
            ${CMAKE_CURRENT_LIST_DIR}/0002-add-missing-directory-to-cmake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    # dllexport support seem to be broken
    OPTIONS -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON
            -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_build_cmake()
vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libwebp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libwebp/COPYING ${CURRENT_PACKAGES_DIR}/share/libwebp/copyright)

vcpkg_copy_pdbs()