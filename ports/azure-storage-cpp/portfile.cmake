if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-storage-cpp
    REF v5.1.0
    SHA512 a072b43482133bcc16d2da013ede2a29cb530ddeb0cdd38ed1f08d2a67fe7c6e2c7b0c5bb5c69b5c5b21de62bddfc20e12766618e6c6721d1221a00d435c1d51
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

