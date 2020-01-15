vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO electronicarts/EABase
    REF edbafca82e4c4e73302e0b5144c5d1f4710db9fa
    SHA512 fb9bd07602fb308864506737813212e47385a164708cd9064fdd4d1893294b228718a2964a0b16d04483f4f4c8a156f7199b60f227e4fc9ac88352f7dcd59672
    HEAD_REF master
    PATCHES
    fix_cmake_install.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/EABaseConfig.cmake.in DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    -DEABASE_BUILD_TESTS:BOOL=OFF
)
vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/EABase)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
