vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/parallelstl
    REF  0241743d73bb405b16d9c4a24b693e4533dc34a7 # 20200330
    SHA512 cd2f1b60639e9da35a722bdef0bc6420ddca064e3bff979d8a6ea591fb43865b7614c811bced642fd5ff1fab659da1dfaa248dc2b321db7f27d0e74544a2f21e
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
