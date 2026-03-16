vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stevengj/nlopt
    REF "v${VERSION}"
    SHA512 c7bc34c3fc00cb714473f5612329291dd3b7f2748a08c83ac0ab1fc719e9ce88c730eeeac88367273dd6e5f78e7afa0bed818374ae50b326fcd25f370abc1909
    HEAD_REF master
)
vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        luksan NLOPT_LUKSAN
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DNLOPT_FORTRAN=OFF
        -DNLOPT_GUILE=OFF
        -DNLOPT_MATLAB=OFF
        -DNLOPT_OCTAVE=OFF
        -DNLOPT_PYTHON=OFF
        -DNLOPT_SWIG=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/nlopt)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
if("NLOPT_LUKSAN" IN_LIST FEATURES)
    vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING" "${SOURCE_PATH}/src/algs/luksan/COPYRIGHT")
else()
    vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/nlopt/NLoptConfig.cmake" "/../../" "/../")

vcpkg_fixup_pkgconfig()
