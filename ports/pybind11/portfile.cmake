include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pybind/pybind11
    REF e43e1cc01ae6d4e4e5ba10557a057d7f3d5ece0d
    SHA512 546a0501c420cbbb21fb458192bae6c8d34bdd4bdbfe47fed22869e09429d6404b4e399e30c36c6d658bf8002339d051efde33685b03a00797b9cfe476cfb98e
    HEAD_REF master
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path(${PYTHON3_DIR})

find_path(_PATH_INCLUDE
    NAMES
        Python.h
    PATHS
        "${CURRENT_INSTALLED_DIR}/include"
        "${CURRENT_INSTALLED_DIR}/include/python3.7"
        "${CURRENT_INSTALLED_DIR}/include/python3.7m"
)

find_library(_PATH_LIBRARY_DEBUG
    NAMES
        python3.7dm
        python37_d
    PATHS
        "${CURRENT_INSTALLED_DIR}/debug/lib"
)

find_library(_PATH_LIBRARY_RELEASE
    NAMES
        python3.7m
        python37
    PATHS
        "${CURRENT_INSTALLED_DIR}/lib"
)

message(STATUS "_PATH_INCLUDE: ${_PATH_INCLUDE}")
message(STATUS "_PATH_LIBRARY_DEBUG: ${_PATH_LIBRARY_DEBUG}")
message(STATUS "_PATH_LIBRARY_RELEASE: ${_PATH_LIBRARY_RELEASE}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPYBIND11_TEST=OFF
        -DPYTHON_MODULE_EXTENSION=.dll
        -DPYTHON_VERSION:STRING=3.7
        -DPYTHON_INCLUDE_DIR:PATH="${_PATH_INCLUDE}"
    OPTIONS_RELEASE
        -DPYTHON_LIBRARY:PATH="${_PATH_LIBRARY_RELEASE}"
    OPTIONS_DEBUG
        -DPYTHON_LIBRARY:PATH="${_PATH_LIBRARY_DEBUG}"
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/)

# copy license
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/pybind11 RENAME copyright)
