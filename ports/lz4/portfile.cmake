
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/lz4-1.7.4.2)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/lz4/lz4/archive/v1.7.4.2.zip"
    FILENAME "lz4-1.7.4.2.zip"
    SHA512 c9a65031225ccda43ad4c7622e9f36762c18e58b4aaf43b1a33f219186fb55c43ca354f574a1591188db39f57631351b1b90f96e0c150e28de08dcb65c6759d0)

vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
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
