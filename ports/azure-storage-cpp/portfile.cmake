include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/azure-storage-cpp-2.6.0)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Azure/azure-storage-cpp/archive/v2.6.0.tar.gz"
    FILENAME "azure-storage-cpp/v2.6.0.tar.gz"
    SHA512 383fc709b04b7a116b553575f27a95b95a66105fe9b96d412fc4f1938e51288f81e49a9578c02993d0bc2a4771265694117b82fd5beaeaf4c32f81eeb8f9be6a
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

