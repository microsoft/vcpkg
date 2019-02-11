include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pybind/pybind11
    REF v2.2.4
    SHA512 6bddf5c885ff92a3e373bcedc6574dfefe8be9ebb6176c6c96d475457466c76bfb982c6df4066cb0fbead4b867f87dbc4fbc1605c80852635016f614330ce041
    HEAD_REF master
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/aliastemplates.patch
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