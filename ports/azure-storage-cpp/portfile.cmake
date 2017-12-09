if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-storage-cpp
    REF v3.0.0
    SHA512 45d0d7f8cc350a16cff0371cdd442e851912c89061acfec559482e8f79cebafffd8681b32a30b878e329235cd3aaad5d2ff797d1148302e3109cf5111df14b97
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/cmake.patch
        ${CMAKE_CURRENT_LIST_DIR}/static-builds.patch
        ${CMAKE_CURRENT_LIST_DIR}/support-cpprest-findpackage.patch
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

