set(PHYSFS_VERSION 3.0.2)

vcpkg_download_distfile(ARCHIVE
    URLS "https://icculus.org/physfs/downloads/physfs-${PHYSFS_VERSION}.tar.bz2"
    "https://hg.icculus.org/icculus/physfs/archive/release-${PHYSFS_VERSION}.tar.bz2"
    FILENAME "physfs-${PHYSFS_VERSION}.tar.bz2"
    SHA512 4024b6c3348e0b6fc1036aac330192112dfe17de3e3d14773be9f06e9a062df5a1006869f21162b4e0b584989f463788a35e64186b1913225c073fea62754472
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${PHYSFS_VERSION}
    PATCHES
        "001-fix-lzmasdk-arm64-windows.patch"
        "002-fix-posix-eintr.patch" # Remove this patch in the next update
        "003-fix-posix-cloexec.patch" # Remove this patch in the next update
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" PHYSFS_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" PHYSFS_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DPHYSFS_BUILD_STATIC=${PHYSFS_STATIC}
        -DPHYSFS_BUILD_SHARED=${PHYSFS_SHARED}
        -DPHYSFS_BUILD_TEST=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
