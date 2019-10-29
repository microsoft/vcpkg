include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO librsync/librsync
    REF 5917692418657dc78c9cbde3a8db4c85f25b9c8d # v2.2.1
    SHA512 2d5ff324b3c95adfffb4aedee1aab51ca66e0c629bde8ada9514bb209cf77bfc678ab78edea449949979206b07ecbc0d2551fad68440cc87ef668835d205d9f6
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
