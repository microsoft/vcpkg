
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/lz4-1.7.5)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/lz4/lz4/archive/v1.7.5.zip"
    FILENAME "lz4-1.7.5.zip"
    SHA512 09968b67a5cd8555f6e1d95b99971a82d228c6d8d9f9dd9e9a33c9633bed9bcf1e370c2ff44e58c6ca72d103c149585b3e83061c690f3e857eb5f53d586f86a4)

vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DLZ4_SKIP_INCLUDES=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_apply_patches(
        SOURCE_PATH ${CURRENT_PACKAGES_DIR}/include
        PATCHES
            ${CMAKE_CURRENT_LIST_DIR}/auto-define-import-macro.patch)
endif()

file(COPY ${SOURCE_PATH}/lib/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/lz4)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/lz4/LICENSE ${CURRENT_PACKAGES_DIR}/share/lz4/copyright)
