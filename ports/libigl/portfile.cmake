vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libigl/libigl
    REF  3cb4894eaf8ea4610467189ca292be349425d44b #2.2.0
    SHA512 339f96e36b6a99ae8301ec2e234e18cecba7b7c42289ed68a26c20b279dce3135405f9b49e292c321fba962d56c083ae61831057bec9a19ad1495e2afa379b8b
    HEAD_REF master
    PATCHES
        fix-dependency.patch
        fix-imgui-set-cond.patch
        install-extra-headers.patch
        fix-config.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    embree LIBIGL_WITH_EMBREE
    opengl LIBIGL_WITH_OPENGL
    glfw LIBIGL_WITH_OPENGL_GLFW
    imgui LIBIGL_WITH_OPENGL_GLFW_IMGUI
    #png LIBIGL_WITH_PNG # Disable this feature due to issue https://github.com/libigl/libigl/issues/1199
    xml LIBIGL_WITH_XML
    #python LIBIGL_WITH_PYTHON # Python binding are in the process of being redone.
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
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
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/libigl/cmake)
vcpkg_copy_pdbs()

# libigl is a header-only library.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

file(INSTALL ${SOURCE_PATH}/LICENSE.GPL DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
