vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO esa/pagmo2
    REF "v${VERSION}"
    SHA512 3d0d171f8069b845016f3604f4054aaf6cab09dd55212a8ac317ba3d9454b4f2c81ee0cc835b1946838c97081da9ed9e6c80dba8e75c11c6ba210a0643dcf13f
    HEAD_REF master
    PATCHES
        0001-doxygen.patch
        0003-disable-werror.patch
        0006-config-find-libipopt.patch
        0007-ipopt-transitive-deps.patch # coin-or-ipopt provides no cmake config
        0008-ipopt-header-search.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ipopt PAGMO_WITH_IPOPT
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
