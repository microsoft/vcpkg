include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stachenov/quazip
    REF v0.9.1
    SHA512 db31f3c7e3d7e95c25090ceb8379643e0b49ed69ece009dd015bee120b2b60f42e73408f580caed3138fa19ca64dcd23a05f16435abb54e2b8df21105c7b42c0
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/QuaZip5/)
vcpkg_copy_pdbs()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/quazip5.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/quazip5.dll ${CURRENT_PACKAGES_DIR}/bin/quazip5.dll)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/quazip5d.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/quazip5d.dll ${CURRENT_PACKAGES_DIR}/debug/bin/quazip5d.dll)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/quazip/ RENAME copyright)