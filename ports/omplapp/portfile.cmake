vcpkg_buildpath_length_warning(37)

# See https://github.com/ompl/omplapp/blob/1.6.0/src/omplapp/CMakeLists.txt#L20-L24
if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
else()
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ompl/omplapp
    REF "${VERSION}"
    SHA512 4dfc8d5ab9d23bc8d383e15e7a9b98cc08c40553ac97728c2bd767fe935fff448ad296db261943fdf56355680bd553464f57d0b691049fec2a3ea3c863473465
    HEAD_REF main
    PATCHES
        reuse-ompl.diff
        export-targets.diff
        boost-program-options.diff
)
file(GLOB find_modules "${SOURCE_PATH}/CMakeModules/Find*.cmake")
file(REMOVE_RECURSE "${SOURCE_PATH}/src/external" ${find_modules})

file(COPY "${CURRENT_INSTALLED_DIR}/share/ompl/CMakeModules" DESTINATION "${SOURCE_PATH}/ompl")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        opengl  CMAKE_REQUIRE_FIND_PACKAGE_OpenGL
    INVERTED_FEATURES
        opengl  CMAKE_DISABLE_FIND_PACKAGE_OpenGL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        -DOMPL_VERSIONED_INSTALL=OFF
        -DOMPL_BUILD_DEMOS=OFF
        -DOMPL_BUILD_PYBINDINGS=OFF
        -DCMAKE_POLICY_DEFAULT_CMP0167=OLD
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Drawstuff=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_flann=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_MORSE=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_ODE=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_PQP=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_spot=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Triangle=ON
)

vcpkg_cmake_install()

# Extending the ompl CMake package
vcpkg_cmake_config_fixup(PACKAGE_NAME ompl)
file(COPY "${CURRENT_PORT_DIR}/omplapp-dependencies.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/ompl")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/omplapp/config.h" "#define OMPLAPP_RESOURCE_DIR \"${CURRENT_PACKAGES_DIR}/share/ompl/resources\"" "")

vcpkg_copy_tools(TOOL_NAMES ompl_benchmark AUTO_CLEAN)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/include/omplapp/CMakeFiles"
    "${CURRENT_PACKAGES_DIR}/share/man"
    "${CURRENT_PACKAGES_DIR}/share/ompl/demos"
    "${CURRENT_PACKAGES_DIR}/share/ompl/resources"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
