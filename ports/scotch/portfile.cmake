if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.inria.fr/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO scotch/scotch
    REF "v${VERSION}"
    SHA512 9566ca800fd47df63844df6ff8b0fbbe8efbdea549914dfe9bf00d3d104a8c5631cfbef69e2677de68dcdb93addaeed158e6f6a373b5afe8cec82ac358946b65
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

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ptscotch    BUILD_PTSCOTCH
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
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

if ("ptscotch" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES dggath dgmap dgord dgscat dgtst AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/doc/CeCILL-C_V1-en.txt")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/scotch/SCOTCHConfig.cmake" "find_dependency(Threads)" "if(NOT WIN32)\nfind_dependency(Threads)\nelse()\nfind_dependency(PThreads4W)\nendif()")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/man"
                    "${CURRENT_PACKAGES_DIR}/man"
                    "${CURRENT_PACKAGES_DIR}/debug/share"
                    )
