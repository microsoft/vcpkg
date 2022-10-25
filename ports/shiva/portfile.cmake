vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Milerius/shiva
        REF 1.0
        SHA512 d1ce33e89b17fa8f82e21b51dfa1308e38c617fea52c34a20b7b6c8643318280df24c043238ddd73ba2dbc139c5b5de1c2cb3add1f5629a54694c78b415d73d1
        HEAD_REF master
        PATCHES no_copy_dll.patch
)

find_library(PYTHON_RELEASE NAMES python310 PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(PYTHON_DEBUG NAMES python310_d python310 PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
include(SelectLibraryConfigurations)
select_library_configurations(PYTHON)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DSHIVA_BUILD_TESTS=OFF
        "-DPYTHON_LIBRARY=${PYTHON_LIBRARIES}"
        "-DPYTHON_LIBRARIES=${PYTHON_LIBRARIES}"
        "-DPYTHON_EXECUTABLE=${CURRENT_INSTALLED_DIR}/tools/python3/python${VCPKG_EXECUTABLE_SUFFIX}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/shiva")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
file(COPY "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/shiva")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/shiva/LICENSE" "${CURRENT_PACKAGES_DIR}/share/shiva/copyright")
