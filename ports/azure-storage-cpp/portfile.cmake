if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-storage-cpp
    REF v6.1.0
    SHA512 bc6a1da6287301b5bb5c31694d508c46447b71043d5b94a90ffe79b6dc045bc111ed0bcf3a7840e096ddc3ef6badbeef7fb905242e272a9f82f483d849a43e61
    HEAD_REF master
    PATCHES
        # on osx use the uuid.h that is part of the osx sdk
        builtin-uuid-osx.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/Microsoft.WindowsAzure.Storage
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

