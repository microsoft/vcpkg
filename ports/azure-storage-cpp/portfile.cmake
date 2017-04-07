include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/azure-storage-cpp-3.0.0)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Azure/azure-storage-cpp/archive/v3.0.0.tar.gz"
    FILENAME "azure-storage-cpp/v3.0.0.tar.gz"
    SHA512 45d0d7f8cc350a16cff0371cdd442e851912c89061acfec559482e8f79cebafffd8681b32a30b878e329235cd3aaad5d2ff797d1148302e3109cf5111df14b97
)
vcpkg_extract_source_archive(${ARCHIVE})

find_path(ATLMFC_PATH NAMES "atlbase.h")
if(ATLMFC_PATH STREQUAL "ATLMFC_PATH-NOTFOUND")
    message(FATAL_ERROR "Could not find ATL. Please ensure you have installed the \"Visual C++ ATL support\" optional feature underneath the Desktop C++ workload.")
endif()

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/static-builds.patch
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

