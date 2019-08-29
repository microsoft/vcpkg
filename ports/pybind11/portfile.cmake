include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pybind/pybind11
    REF e43e1cc01ae6d4e4e5ba10557a057d7f3d5ece0d
    SHA512 546a0501c420cbbb21fb458192bae6c8d34bdd4bdbfe47fed22869e09429d6404b4e399e30c36c6d658bf8002339d051efde33685b03a00797b9cfe476cfb98e
    HEAD_REF master
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/aliastemplates.patch
)

vcpkg_find_acquire_program(PYTHON3)

get_filename_component(PYPATH ${PYTHON3} PATH)
set(ENV{PATH} "$ENV{PATH};${PYPATH}") #TODO: Use vcpkg_add_to_path

if(VCPKG_TARGET_IS_WINDOWS)
    set(PYTHON3_LIBS  -DPYTHON_LIBRARIES=\"optimized\\\\\\\\;${CURRENT_INSTALLED_DIR}/lib/python36.lib\\\\\\\\;debug\\\\\\\\;${CURRENT_INSTALLED_DIR}/debug/lib/python36_d.lib\"
                      -DPYTHONLIBS_FOUND=ON
                      -DPYTHON_INCLUDE_DIRS=${CURRENT_INSTALLED_DIR}/include)
else()
    set(PYTHON3_LIBS)
endif()
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPYBIND11_TEST=OFF
        -DPYTHON_MODULE_EXTENSION=${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}
        ${PYTHON3_LIBS}
        -DVCPKG_LIBTRACK_DEACTIVATE=ON
    OPTIONS_RELEASE
        -DPYTHON_IS_DEBUG=OFF
    OPTIONS_DEBUG
        -DPYTHON_IS_DEBUG=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/)

# copy license
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/pybind11/copyright)