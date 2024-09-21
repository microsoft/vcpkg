if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.inria.fr/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO scotch/scotch
    REF b43864123e820e3ca541bfecd3738aed385a4c47
    SHA512 66d84624ff608a8557789b9f48e83694151f824c4be57ce294863390b4d2f6702bed381f9dbb1527456414385e0a7793752750d7d2731f551d2f34e2aaa4f6b4
    HEAD_REF master
    PATCHES fix-build.patch
)

vcpkg_find_acquire_program(FLEX)
cmake_path(GET FLEX PARENT_PATH FLEX_DIR)
vcpkg_add_to_path("${FLEX_DIR}")

vcpkg_find_acquire_program(BISON)
cmake_path(GET BISON PARENT_PATH BISON_DIR)
vcpkg_add_to_path("${BISON_DIR}")

if(VCPKG_TARGET_IS_WINDOWS)
    #Uses gcc intrinsics otherwise
    string(APPEND VCPKG_C_FLAGS     " -DGRAPHMATCHNOTHREAD")
    string(APPEND VCPKG_CXX_FLAGS   " -DGRAPHMATCHNOTHREAD")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_PTSCOTCH=OFF # Requires MPI
        -DBUILD_LIBESMUMPS=OFF
        -DBUILD_LIBSCOTCHMETIS=OFF
        -DTHREADS=ON
        -DMPI_THREAD_MULTIPLE=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/scotch")
vcpkg_copy_tools(TOOL_NAMES
    acpl amk_ccc amk_fft2 amk_grf amk_hy
    amk_m2 amk_p2 atst gbase gcv gmap gmk_hy
    gmk_m2 gmk_m3 gmk_msh gmk_ub2 gmtst
    gord gotst gscat gtst mcv mmk_m2 mmk_m3
    mord mtst
    AUTO_CLEAN
    )

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/doc/CeCILL-C_V1-en.txt")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/scotch/SCOTCHConfig.cmake" "find_dependency(Threads)" "if(NOT WIN32)\nfind_dependency(Threads)\nelse()\nfind_dependency(PThreads4W)\nendif()")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/man"
                    "${CURRENT_PACKAGES_DIR}/man"
                    )
