include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pybind/pybind11
    REF v2.2.1
    SHA512 1bc0646862fabef1111c05403a7238965ce5661a6f53945a1b7c4faad33f039d2ea278de64190099a8ae4fd66487a070de59334a7f32e187060bbbc7e0c3060e
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