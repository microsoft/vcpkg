include(vcpkg_common_functions)

set(WEBP_VERSION 0.6.1)
set(WEBP_HASH f2512db136c9d9a455463134df1aff427f9d603aedd4cabd97ad26f3fa717806427f10a3162a94322900f2457268c867f1b655fc2a6a99d58c4141145979797a)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libwebp-${WEBP_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/webmproject/libwebp/archive/v${WEBP_VERSION}.zip"
    FILENAME "libwebp-${WEBP_VERSION}.zip"
    SHA512 ${WEBP_HASH}
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/build_fixes.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_DEBUG_POSTFIX=d
        -DWEBP_BUILD_MUX=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libwebp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libwebp/COPYING ${CURRENT_PACKAGES_DIR}/share/libwebp/copyright)

vcpkg_copy_pdbs()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/FindWebP.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libwebp)
