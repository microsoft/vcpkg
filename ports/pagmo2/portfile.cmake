vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO esa/pagmo2
    REF 27ae9159f4fcd11bb93de0ae8189d15352655b0a # v2.19.0
    SHA512 9f85fe5dbce0542bf3c52918562da9632ec64ee2839d1d2404bf5a6caa4c854c654ca1735c617a15208a597a79a8c28431378e6968335b1c3e9e8d86b6d7d237
    HEAD_REF master
    PATCHES
        doxygen.patch
        find-tbb.patch
        disable-werror.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
   FEATURES
   nlopt PAGMO_WITH_NLOPT
)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" PAGMO_BUILD_STATIC_LIBRARY)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DPAGMO_BUILD_TESTS=OFF
        -DPAGMO_BUILD_BENCHMARKS=OFF
        -DPAGMO_BUILD_TUTORIALS=OFF
        -DPAGMO_WITH_EIGEN3=ON
        -DPAGMO_BUILD_STATIC_LIBRARY=${PAGMO_BUILD_STATIC_LIBRARY}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/pagmo")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.lgpl3" "${SOURCE_PATH}/COPYING.gpl3")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
