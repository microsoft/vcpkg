vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/parallelstl #20191218
    REF  37761e15f62c03b7eb179db64ef930a69f33dfac
    SHA512 dc8c875f692043b6f10ce7faf034e07536978537ea2a3d545be499cfa047f0c362c5109eb744a41dc0c92bd0fc56d98505183444bd376aeb257c9204480e6668
    HEAD_REF master
    PATCHES 
        fix-cmakelist.txt.patch
        fix-config.cmake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
      -DPARALLELSTL_USE_PARALLEL_POLICIES=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/ParallelSTL)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)