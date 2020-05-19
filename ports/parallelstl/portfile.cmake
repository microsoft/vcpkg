vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/parallelstl #20191218
    REF  37761e15f62c03b7eb179db64ef930a69f33dfac
    SHA512 4609394f59f4f420faf9c82b77c6a24ecba53066e8af2ec8ceaa2d88e6c5355847efff95c35161f9fc3f1a59f4d67f616bd8aa023f28d4b330d75e705a7a3229
    HEAD_REF master
    PATCHES 
        fix-cmakelist.patch
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