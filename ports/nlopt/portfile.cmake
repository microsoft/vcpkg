vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stevengj/nlopt
    REF "v${VERSION}"
    SHA512 cb294caa5532e11ae0d22ed849705920bbae79f712144c840a5ca865ef8e6a15c6c9540c81ced0c3c05b9f44c360d50f74e235e69d893be34b7e1c5599f07c71
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
