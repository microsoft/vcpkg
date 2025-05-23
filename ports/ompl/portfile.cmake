vcpkg_buildpath_length_warning(37)

# See https://github.com/ompl/ompl/blob/1.6.0/src/ompl/CMakeLists.txt#L52-L56
if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
else()
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ompl/ompl
    REF "${VERSION}"
    SHA512 d1024d7cc8e309a1df94a950be67eefae1e66abaccd6b6b8980939559aee3d73c05c838ab24c818b6b57ce6c4b3181fde7595d3d1dd36d6cd0c6d125338084ac
    HEAD_REF main
    PATCHES
        0001_Export_targets.patch
        0002_Fix_config.patch
        0003_disable-pkgconfig.patch
        0004_include_chrono.patch # https://github.com/ompl/ompl/pull/1201
)
file(GLOB find_modules "${SOURCE_PATH}/CMakeModules/Find*.cmake")
file(REMOVE_RECURSE "${SOURCE_PATH}/src/external" ${find_modules})
# The ompl/omplapp ports don't support python features.
file(COPY "${CURRENT_PORT_DIR}/FindPython.cmake" DESTINATION "${SOURCE_PATH}/CMakeModules")

set(ENV{PYTHON_EXEC} "PYTHON_EXEC-NOTFOUND")
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
        -DCMAKE_POLICY_DEFAULT_CMP0167=OLD
        -DCMAKE_DISABLE_FIND_PACKAGE_castxml=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_flann=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_MORSE=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_ODE=ON
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

# Used by port omplapp
file(GLOB cmake_modules "${SOURCE_PATH}/CMakeModules/*.cmake")
file(COPY ${cmake_modules} DESTINATION "${CURRENT_PACKAGES_DIR}/share/ompl/CMakeModules")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
