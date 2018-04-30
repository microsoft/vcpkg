if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-storage-cpp
    REF v3.2.1
    SHA512 8d1e8de439e52f53eb28b77e8adf394468f4861c2c4c1f79ec1437c72e3fc0bc871e4e2662ee58090748915b0f12ce6736a7cc6ede619d332686b9fb6a026c9f
    HEAD_REF master
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/cmake.patch
        ${CMAKE_CURRENT_LIST_DIR}/static-builds.patch
        ${CMAKE_CURRENT_LIST_DIR}/support-cpprest-findpackage.patch
        ${CMAKE_CURRENT_LIST_DIR}/glibmm-cmake.patch
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

