vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stevengj/nlopt
    REF "v${VERSION}"
    SHA512 7668db6997ba141ee1759f222bad23a7854aa17962470653ddb5824c25100b50f52c462441f0cc12a62e2322ff084c7f7b7fab09471b0acb13a861d7f7575655
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
