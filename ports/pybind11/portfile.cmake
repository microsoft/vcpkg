vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pybind/pybind11
    REF v2.10.0
    SHA512 93112ce530a0652b2b4458a137b4a35f2fd8607f82ad96698ef422128d0b53e16e1d06c239ee4643b821acafae09c74eb0f72bc4ee5584aa9fcdaff4d79980d9
    HEAD_REF master
    PATCHES fix-usage.patch
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
