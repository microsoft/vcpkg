if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-storage-cpp
    REF v7.0.0
    SHA512 2187bd4d640ff1630f4f20d2717ea0219f7835e524b1db5b89563b5b525a34200a33693030d9e004db9cfe1df905b6c76ffd709f9e6cb2e2861ba1c1f8d062db
    HEAD_REF master
    PATCHES
        remove-gcov-dependency.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/Microsoft.WindowsAzure.Storage
    PREFER_NINJA
    OPTIONS
        -DCMAKE_FIND_FRAMEWORK=LAST
        -DBUILD_TESTS=OFF
        -DBUILD_SAMPLES=OFF
        -DGETTEXT_LIB_DIR=${CURRENT_INSTALLED_DIR}/include
)

vcpkg_install_cmake()

file(INSTALL
    ${SOURCE_PATH}/LICENSE.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/azure-storage-cpp RENAME copyright)
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

