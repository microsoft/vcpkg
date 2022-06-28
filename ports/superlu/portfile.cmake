vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiaoyeli/superlu
    REF a3d5233770f0caad4bc4578b46d3b26af99e9c19
    SHA512 c07e64be51ddef7774a367e1309ef4e596e93571531ec58a0c7b9db60a3db8b3a4a8b1262d66fcd512ad467db5df59a3726db342b259e392a08f56f5dd67c6ef
    HEAD_REF master
    PATCHES
      fix-libm.patch
      remove-make.inc.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    -DXSDK_ENABLE_Fortran=OFF
    -Denable_tests=OFF
    -Denable_blaslib=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_fixup_pkgconfig()
