include(vcpkg_common_functions)
set(PHYSFS_VERSION 3.0.2)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/physfs-${PHYSFS_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://icculus.org/physfs/downloads/physfs-${PHYSFS_VERSION}.tar.bz2"
    FILENAME "physfs-${PHYSFS_VERSION}.tar.bz2"
    SHA512 4024b6c3348e0b6fc1036aac330192112dfe17de3e3d14773be9f06e9a062df5a1006869f21162b4e0b584989f463788a35e64186b1913225c073fea62754472
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${PHYSFS_VERSION}
)

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
