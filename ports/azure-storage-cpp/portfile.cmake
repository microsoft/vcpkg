if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-storage-cpp
    REF v3.2.0
    SHA512 841c548986de743b508edd149441727e76f66ba09a99454006d2742547267046833062501e79ff2138d6bcad37740f7009cce4590bbdf40b48b935b989959267
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

