vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stevengj/nlopt
    REF v2.7.1
    SHA512 e23cb522fc696010574c14b72be85acc0f8ccf0bf208bf2b8789c57d6c5a6e6d419ee10330581518b1c1567018ae909b626ce7761d4fbd5bf112916871e420e2
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNLOPT_FORTRAN=OFF
        -DNLOPT_PYTHON=OFF
        -DNLOPT_OCTAVE=OFF
        -DNLOPT_MATLAB=OFF
        -DNLOPT_GUILE=OFF
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
