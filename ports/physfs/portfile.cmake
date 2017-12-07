if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

include(vcpkg_common_functions)
set(PHYSFS_VERSION 2.0.3)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/physfs-${PHYSFS_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://icculus.org/physfs/downloads/physfs-${PHYSFS_VERSION}.tar.bz2"
    FILENAME "physfs-${PHYSFS_VERSION}.tar.bz2"
    SHA512 47eff0c81b8dc3bb526766b0a8ad2437d2951867880116d6e6e8f2ec1490e263541fb741867fed6517cc3fa8a9c5651b36e3e02a499f19cfdc5c7261c9707e80
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/export-symbols-in-shared-build-only.patch)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" PHYSFS_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" PHYSFS_SHARED) 

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DPHYSFS_BUILD_STATIC=${PHYSFS_STATIC}
        -DPHYSFS_BUILD_SHARED=${PHYSFS_SHARED}
        -DPHYSFS_BUILD_TEST=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/physfs)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/physfs/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/physfs/copyright)
