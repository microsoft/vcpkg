vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stevengj/nlopt
    REF "v${VERSION}"
    SHA512 72dfb5374f89f6a507f0a22317fd76b4fc26795d7868842e02dc67a76fbbaf04fb769cec7b366774f5d2a1ed0c2305878c9d82e0ef85e449f9350cdcaa58c262
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
        -DNLOPT_JAVA=OFF
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
