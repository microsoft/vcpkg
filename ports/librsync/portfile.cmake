include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO librsync/librsync
    REF 27f738650c20fef1285f11d85a34e5094a71c06f # v2.3.1
    SHA512 5f94d62568e70073943b331e4d8bf75cca719dd1550d70dde7534503fbdd6b8f4d54e292c18734beb8c349d5ebca52dc3226b12b53d18b8b7306f0a7f936133c
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
