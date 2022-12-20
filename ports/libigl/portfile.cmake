vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libigl/libigl
    REF  e60423e28c86b6aa2a3f6eb0112e8fd881f96777 #2.3.0
    SHA512 3fecb710825e58745c1d67eab694ee365a5b86151a5a1ca3758c1000c124059d38dbc78e8c6e941be6d85a716f928ed8fea42bb6007b8e24da0123332c2c96da
    HEAD_REF master
    PATCHES
        fix-dependency.patch
        install-extra-headers.patch
        fix-config.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        embree LIBIGL_WITH_EMBREE
        opengl LIBIGL_WITH_OPENGL
        glfw   LIBIGL_WITH_OPENGL_GLFW
        imgui  LIBIGL_WITH_OPENGL_GLFW_IMGUI
        #png LIBIGL_WITH_PNG # Disable this feature due to issue https://github.com/libigl/libigl/issues/1199
        xml    LIBIGL_WITH_XML
        #python LIBIGL_WITH_PYTHON # Python binding are in the process of being redone.
        cgal   LIBIGL_WITH_CGAL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS ${FEATURE_OPTIONS}
        -DLIBIGL_BUILD_PYTHON=OFF
        -DLIBIGL_EXPORT_TARGETS=ON
        -DLIBIGL_USE_STATIC_LIBRARY=OFF # Header-only mode
        -DLIBIGL_WITH_COMISO=OFF
        -DLIBIGL_WITH_TETGEN=OFF
        -DLIBIGL_WITH_TRIANGLE=OFF
        -DLIBIGL_WITH_PREDICATES=OFF
        -DLIBIGL_BUILD_TUTORIALS=OFF
        -DLIBIGL_WITH_PNG=OFF
        -DLIBIGL_BUILD_TESTS=OFF
        -DPYTHON_EXECUTABLE=${PYTHON2}
    MAYBE_UNUSED_VARIABLES
        PYTHON_EXECUTABLE
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/libigl/cmake)
vcpkg_copy_pdbs()

# libigl is a header-only library.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE.GPL" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
