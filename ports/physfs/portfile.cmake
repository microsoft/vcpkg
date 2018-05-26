include(vcpkg_common_functions)
set(PHYSFS_VERSION 3.0.1)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/physfs-${PHYSFS_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://icculus.org/physfs/downloads/physfs-${PHYSFS_VERSION}.tar.bz2"
    FILENAME "physfs-${PHYSFS_VERSION}.tar.bz2"
    SHA512 ddf3b075ccb506da5e9a1ce96001be402752b9b777c2e816a85d48aff3626ff0886ea43eb07bd300fe3a9f59b9a002f54d822c51d483a4ee94b38378534c1879
)
vcpkg_extract_source_archive(${ARCHIVE})

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
