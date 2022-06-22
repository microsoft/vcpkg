vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pybind/pybind11
    REF c3e9173f0f6da05a8463db093c4bc85934872c84
    SHA512 0ec32d421158ad73c286ddb8ab661847f015440d79d966a02a36232c31e2cbda557bee0ba7addb5f9bd7bb0650c4d3db60e8c50390cc641c402ab7fac8a60425
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/pybind11/pybind11Tools.cmake" 
                    [=[find_package(PythonLibsNew ${PYBIND11_PYTHON_VERSION} MODULE REQUIRED ${_pybind11_quiet})]=]
                    [=[find_package(PythonLibs ${PYBIND11_PYTHON_VERSION} MODULE REQUIRED ${_pybind11_quiet})]=]) # CMake's PythonLibs works better with vcpkg 

# copy license
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
