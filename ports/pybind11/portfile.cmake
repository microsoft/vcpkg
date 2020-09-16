vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pybind/pybind11
    REF 3b1dbebabc801c9cf6f0953a4c20b904d444f879 # v2.5.0
    SHA512 1a75d29447dbba96eebf8ecdebad1be0dd5327c32f5122b0ece9d9ec22eae4feacd0efb3a5070b3a135a892b1682c7215b0c529b179493694df932945a379f4c
    HEAD_REF master
)

# pybind master allows opting into the builtin cmake find module with -DPYBIND11_FINDPYTHON-ON.
# When the upstream port is updated, remove all of this and change the options to just:
# -DPYBIND11_TEST=OFF -DPYBIND11_FINDPYTHON=ON
find_program(PYTHON_EXECUTABLE NAMES python python3.8 PATHS "${CURRENT_INSTALLED_DIR}/tools/python3" NO_DEFAULT_PATH)
find_library(PYTHON_LIBRARY_DEBUG NAMES python38_d python3.8_d PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(PYTHON_LIBRARY_RELEASE NAMES python38 python3.8 PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPYBIND11_TEST=OFF
        -DPYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}
        -DPYTHONLIBS_FOUND=ON
        -DPYTHON_INCLUDE_DIRS=${CURRENT_INSTALLED_DIR}/include
        -DPYTHON_MODULE_EXTENSION=.dll
    OPTIONS_RELEASE
        -DPYTHON_IS_DEBUG=OFF
        -DPYTHON_LIBRARIES=${PYTHON_LIBRARY_DEBUG}
    OPTIONS_DEBUG
        -DPYTHON_IS_DEBUG=ON
        -DPYTHON_LIBRARIES=${PYTHON_LIBRARY_RELEASE}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/pybind11)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/)

# copy license
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
