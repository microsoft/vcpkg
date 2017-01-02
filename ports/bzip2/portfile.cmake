
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/bzip2-1.0.6)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz"
    FILENAME "bzip2-1.0.6.tar.gz"
    SHA512 00ace5438cfa0c577e5f578d8a808613187eff5217c35164ffe044fbafdfec9e98f4192c02a7d67e01e5a5ccced630583ad1003c37697219b0f147343a3fdd12)
    
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/fix-import-export-macros.patch)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_DEBUG
        -DBZIP2_SKIP_HEADERS=ON
        -DBZIP2_SKIP_TOOLS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_PACKAGES_DIR}/include
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/auto-define-import-macro.patch)
endif()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/bzip2)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/bzip2/LICENSE ${CURRENT_PACKAGES_DIR}/share/bzip2/copyright)
