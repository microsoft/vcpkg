
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/xz-5.2.2)
vcpkg_download_distfile(ARCHIVE
    URLS "http://tukaani.org/xz/xz-5.2.2.tar.gz"
    FILENAME "xz-5.2.2.tar.gz"
    SHA512 8d6249f93c5c43e1c8eeb21f93b22330fd54575e20bbb4af3d06721192d9f0ca3351878964c9640238ac410b7dd9f16329793c7be7355c7ca0db92c6db6ab813)
    
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_DEBUG
        -DLIBLZMA_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_apply_patches(
        SOURCE_PATH ${CURRENT_PACKAGES_DIR}/include
        PATCHES
            ${CMAKE_CURRENT_LIST_DIR}/auto-define-lzma-api-static.patch)
endif()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/liblzma)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/liblzma/COPYING ${CURRENT_PACKAGES_DIR}/share/liblzma/copyright)
