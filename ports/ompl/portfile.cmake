vcpkg_buildpath_length_warning(37)

# See https://github.com/ompl/ompl/blob/1.7.0/src/ompl/CMakeLists.txt#L37-L41
if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
else()
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ompl/ompl
    REF "${VERSION}"
    SHA512 359d0cb8d1a1735d608c8e10bbb233d80fdcc7ec0314a0b7bcb6b611592d0c6ebdb9dcd4aaf8da2369754cf50cc38347d2634305bc430abc07d7b981360990cf
    HEAD_REF main
    PATCHES
        0001-disable-pkgconfig.patch
)

# Remove internal find module files
file(GLOB find_modules "${SOURCE_PATH}/CMakeModules/Find*.cmake")
file(REMOVE_RECURSE ${find_modules})
# Copy fake script. The ompl/omplapp ports don't support python features.
file(COPY "${CURRENT_PORT_DIR}/FindPython.cmake" DESTINATION "${SOURCE_PATH}/CMakeModules")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DOMPL_VERSIONED_INSTALL=OFF
        -DOMPL_REGISTRATION=OFF
        -DOMPL_BUILD_DEMOS=OFF
        -DOMPL_BUILD_TESTS=OFF
        -DOMPL_BUILD_PYBINDINGS=OFF
        -DOMPL_BUILD_PYTESTS=OFF
        -DR_EXEC=R_EXEC-NOTFOUND
        -DCMAKE_DISABLE_FIND_PACKAGE_castxml=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_flann=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_spot=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Triangle=ON
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH share/ompl/cmake)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/man"
    "${CURRENT_PACKAGES_DIR}/share/ompl/demos"
)

# Install CMake modules (used by port omplapp)
file(GLOB cmake_modules "${SOURCE_PATH}/CMakeModules/*.cmake")
file(COPY ${cmake_modules} DESTINATION "${CURRENT_PACKAGES_DIR}/share/ompl/CMakeModules")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
