vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pybind/pybind11
    REF "v${VERSION}"
    SHA512 3894400f04cd08e2dbb14b3d696339f0364434f1d6f8bb057338ac88157ec7491b2df1e1e46ebd5abccdcd5775c5e9238de6404f0db87f64f5a1802db3a5b18c
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPYBIND11_TEST=OFF
        -DPYBIND11_FINDPYTHON=ON
    OPTIONS_RELEASE
        -DPYTHON_IS_DEBUG=OFF
    OPTIONS_DEBUG
        -DPYTHON_IS_DEBUG=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/pybind11")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/pybind11/pybind11Tools.cmake" 
                    [=[find_package(PythonLibsNew ${PYBIND11_PYTHON_VERSION} MODULE REQUIRED ${_pybind11_quiet})]=]
                    [=[find_package(PythonLibs ${PYBIND11_PYTHON_VERSION} MODULE REQUIRED ${_pybind11_quiet})]=]) # CMake's PythonLibs works better with vcpkg 

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
