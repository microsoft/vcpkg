vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stevengj/nlopt
    REF "v${VERSION}"
    SHA512 c7bc34c3fc00cb714473f5612329291dd3b7f2748a08c83ac0ab1fc719e9ce88c730eeeac88367273dd6e5f78e7afa0bed818374ae50b326fcd25f370abc1909
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNLOPT_FORTRAN=OFF
        -DNLOPT_GUILE=OFF
        -DNLOPT_LUKSAN=OFF
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/nlopt/NLoptConfig.cmake" "/../../" "/../")

vcpkg_fixup_pkgconfig()
