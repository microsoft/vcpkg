if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-storage-cpp
    REF v5.2.0
    SHA512 345ddfcececc7b38e65dff96c971eadc41ce7255131f1bc9995dd8fed0c69cc3b48c6838152e30c57014bf2017bde0c819a09b7d6b4abaa089a7ae023633262e
    HEAD_REF master
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/pplx-do-while.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/Microsoft.WindowsAzure.Storage
    OPTIONS
        -DCMAKE_FIND_FRAMEWORK=LAST
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

