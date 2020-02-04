vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pybind/pybind11
    REF 80d452484c5409444b0ec19383faa84bb7a4d351 # v2.4.3
    SHA512 987f8c075ff3e4f90ab27a6121f3767a82939e35cd2143649819c8d39b09d1c234d39fa204ed5f6bd1d9ec97c275f590df358769d7726a16ccb720a91c550883
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

message(VERBOSE "_PATH_INCLUDE: ${_PATH_INCLUDE}")
message(VERBOSE "_PATH_LIBRARY_DEBUG: ${_PATH_LIBRARY_DEBUG}")
message(VERBOSE "_PATH_LIBRARY_RELEASE: ${_PATH_LIBRARY_RELEASE}")

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
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
