include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO electronicarts/EABase
    REF 6f27a2f7aa21f2d71ae8c6bc1d889d0119677a56
    SHA512 9176fb2d508cf023c3c16c61a511196a2f6af36172145544bba44062a00ca7591e54e4fc16ac13562ef0e2d629b626f398bff3669b4cdb7ba0068548d6a53883
    HEAD_REF master
    PATCHES
    fix_cmake_install.patch
    fix_uwp.patch
)

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
