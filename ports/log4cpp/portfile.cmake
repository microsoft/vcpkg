vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO orocos-toolchain/log4cpp
    REF v2.9.1
    SHA512 5bd222c820a15c5d96587ac9fe864c3e2dc0fbce8389692be8dd41553ac0308002ad8d6f4ef3ef10af1d796f8ded410788d1a5d22f15505fac639da3f73e3518
    HEAD_REF master
    PATCHES
        fix-install-targets.patch
        Fix-StaticSupport.patch
        fix-includepath.patch
		fix-export-targets.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_fixup_cmake_targets(CONFIG_PATH share/${PORT})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/log4cpp-config.in.cmake
    ${CURRENT_PACKAGES_DIR}/share/${PORT}/log4cpp-config.cmake
    @ONLY
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
