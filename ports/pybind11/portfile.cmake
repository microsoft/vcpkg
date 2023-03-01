vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pybind/pybind11
    REF "v${VERSION}"
    SHA512 040f109ec870516acdaebc5133ccbba9e3ed7ff93214a66997cf4b8366c209322f3c902c283040826c7e585c3ea2259caf62d90d0b475bfa33d21e459dd54df1
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

# copy license
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
