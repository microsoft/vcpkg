include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pybind/pybind11
    REF v2.2.0
    SHA512 65d8c2c9ba77b25577dd330356ef9cc8f9af924b1d578c28176f230c6f6a88cfd335cc01cc5e010bb8e641a000a78cfcaa1a1367b438e7c6e0d40ea511494a5a
    HEAD_REF master
)

vcpkg_find_acquire_program(PYTHON3)

get_filename_component(PYPATH ${PYTHON3} PATH)
set(ENV{PATH} "$ENV{PATH};${PYPATH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPYBIND11_TEST=OFF
        -DPYTHONLIBS_FOUND=ON
        -DPYTHON_INCLUDE_DIRS=${CURRENT_INSTALLED_DIR}/include
        -DPYTHON_MODULE_EXTENSION=.dll
    OPTIONS_RELEASE
        -DPYTHON_IS_DEBUG=OFF
        -DPYTHON_LIBRARIES=${CURRENT_INSTALLED_DIR}/lib/python36.lib
    OPTIONS_DEBUG
        -DPYTHON_IS_DEBUG=ON
        -DPYTHON_LIBRARIES=${CURRENT_INSTALLED_DIR}/debug/lib/python36_d.lib
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/)

# copy license
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/pybind11/copyright)