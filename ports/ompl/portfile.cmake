vcpkg_buildpath_length_warning(37)

# No symbols are exported for MSVC DLLs.
# See https://github.com/ompl/ompl/blob/2.0.2/CMakeLists.txt#L25-L31
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ompl/ompl
    REF "${VERSION}"
    SHA512 21e6e1bbc679f548aa11fa27fd9e4683ed6227849da8dcc7cae8dc912e807374f0e990d3435bcbb8c4c212196f6aecbf400b4546ad2b190cac461cd3b44bee8c
    HEAD_REF main
    PATCHES
        0001-disable-pkgconfig.patch
)

# Remove internal find module files
file(GLOB find_modules "${SOURCE_PATH}/CMakeModules/Find*.cmake")
file(REMOVE_RECURSE ${find_modules})
# Copy fake script. The ompl/omplapp ports don't support python features.
file(COPY "${CURRENT_PORT_DIR}/FindPython.cmake" DESTINATION "${SOURCE_PATH}/CMakeModules")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" OMPL_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DOMPL_BUILD_SHARED=${OMPL_BUILD_SHARED}
        -DOMPL_BUILD_VAMP=OFF
        -DOMPL_BUILD_PYTHON_BINDINGS=OFF
        -DOMPL_VERSIONED_INSTALL=OFF
        -DOMPL_BUILD_DEMOS=OFF
        -DOMPL_BUILD_TESTS=OFF
        -DR_EXEC=R_EXEC-NOTFOUND
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_flann=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_spot=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Triangle=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_yaml-cpp=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/ompl/cmake)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/bin/ompl_benchmark_statistics.py"
    "${CURRENT_PACKAGES_DIR}/debug/bin/ompl_benchmark_statistics.py"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/man"
    "${CURRENT_PACKAGES_DIR}/share/ompl/demos"
)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Install CMake modules (used by port omplapp)
file(GLOB cmake_modules "${SOURCE_PATH}/CMakeModules/*.cmake")
file(COPY ${cmake_modules} DESTINATION "${CURRENT_PACKAGES_DIR}/share/ompl/CMakeModules")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
