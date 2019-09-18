include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pybind/pybind11
    REF e43e1cc01ae6d4e4e5ba10557a057d7f3d5ece0d
    SHA512 546a0501c420cbbb21fb458192bae6c8d34bdd4bdbfe47fed22869e09429d6404b4e399e30c36c6d658bf8002339d051efde33685b03a00797b9cfe476cfb98e
    HEAD_REF master
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/adaptions.patch
        ${CMAKE_CURRENT_LIST_DIR}/aliastemplates.patch
        ${CMAKE_CURRENT_LIST_DIR}/cpp14.patch
)

vcpkg_find_acquire_program(PYTHON3)

get_filename_component(PYPATH ${PYTHON3} PATH)
set(ENV{PATH} "$ENV{PATH};${PYPATH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPYBIND11_TEST=OFF
        -DPYBIND11_CPP_STANDARD="-std=c++14"
        -DPYTHONLIBS_FOUND=ON
        -DPYTHON_INCLUDE_DIRS=${CURRENT_INSTALLED_DIR}/include/python3.7m
        -DPYTHON_MODULE_EXTENSION=.so
    OPTIONS_RELEASE
        -DPYTHON_IS_DEBUG=OFF
        -DPYTHON_LIBRARIES=${CURRENT_INSTALLED_DIR}/lib/libpython3.7m.a
    OPTIONS_DEBUG
        -DPYTHON_IS_DEBUG=ON
        -DPYTHON_LIBRARIES=${CURRENT_INSTALLED_DIR}/debug/lib/libpython3.7dm.a
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/)

# copy license
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/pybind11/copyright)