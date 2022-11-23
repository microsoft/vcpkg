vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO esa/pagmo2
    REF v2.18.0
    SHA512 026f038e979bb884bdc4e465bd60ffe60d3d74d38159a70897da7c890230450a0457a943e25c8bdb3f17bafdaa388a6a21f6d44502b4d08860dae6cb4e75a477
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
