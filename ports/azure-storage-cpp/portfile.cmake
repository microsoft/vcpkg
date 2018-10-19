if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-storage-cpp
    REF v5.1.1
    SHA512 e5983d767681cf82a68af3c983a83515a2a7a3b5bf2ffbadcd2992dbcdf213bb322f8d0c4369a4c729ac7536e3e0f52e44cde012cbe1f9464df3ad901f635b6a
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

