include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/azure-storage-cpp-2.5.0)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Azure/azure-storage-cpp/archive/v2.5.0.tar.gz"
    FILENAME "azure-storage-cpp/v2.5.0.tar.gz"
    SHA512 128e02f4c4f741083b7860a1aacabaeee5616684d6a5f7f1b3a88abf7f74e6c46610ed62def2a743e67a20a1d12604b9c44c202d94b56ca0ca02847a2b6c9e1b
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/cmake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/Microsoft.WindowsAzure.Storage
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_SAMPLES=OFF
)

vcpkg_install_cmake()

file(INSTALL
    ${SOURCE_PATH}/LICENSE.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/azure-storage-cpp RENAME copyright)
file(REMOVE_RECURSE 
    ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

