include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO librsync/librsync
    REF v2.0.2
    SHA512 5d2bc1d62b37e9ed7416203615d0a0e3c05c4c884b5da63eda10dd5c985845b500331bce226e4d45676729382c85b41528282e25d491afda31ba434ac0fefad7
    HEAD_REF master
    PATCHES
        001-enable-static-libs.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_RDIFF:BOOL=OFF
            -DENABLE_COMPRESSION:BOOL=OFF
            -DENABLE_TRACE:BOOL=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/rsync.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/rsync.dll ${CURRENT_PACKAGES_DIR}/bin/rsync.dll)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/rsync.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/rsync.dll ${CURRENT_PACKAGES_DIR}/debug/bin/rsync.dll)
endif()

file(INSTALL
    ${SOURCE_PATH}/COPYING
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/librsync RENAME copyright
)

vcpkg_copy_pdbs()
