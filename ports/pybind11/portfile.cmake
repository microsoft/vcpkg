vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pybind/pybind11
    REF "v${VERSION}"
    SHA512 051c2608c37612e857c00ac48429d1c26c14336f20988fb447df25b345b28c5b97ccb80f4227c54de4ef2bd4f8ea3d550acc4a5bb2dd86d65dc1915fdca36719
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
