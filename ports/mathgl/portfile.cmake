set(MATHGL_VERSION "2.5")

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mathgl/mathgl
    REF mathgl%20${MATHGL_VERSION}
    FILENAME "mathgl-${MATHGL_VERSION}.tar.gz"
    SHA512 1fe27962ffef8d7127c4e1294d735e5da4dd2d647397f09705c3ca860f90bd06fd447ff614e584f3d2b874a02262c5518be37d59e9e0a838dd5b8b64fd77ef9d
    PATCHES
        cmake-config.patch
        dependencies.patch
        linkage.patch
        fix_attribute.patch
        fix_default_graph_init.patch
        fix_arma_sprintf.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    arma    enable-arma
    fltk    enable-fltk
    gif     enable-gif
    glut    enable-glut
    gsl     enable-gsl
    hdf5    enable-hdf5
    jpeg    enable-jpeg
    opengl  enable-opengl
    png     enable-png
    qt5     enable-qt5
    wx      enable-wx
    zlib    enable-zlib
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DMathGL_INSTALL_CMAKE_DIR:STRING=share/mathgl2
        -DCMAKE_POLICY_DEFAULT_CMP0127=NEW # cmake_dependent_option condition syntax
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mgl2/dllexport.h" "#ifdef MGL_STATIC_DEFINE" "#if 1")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mgl2/dllexport.h" "#ifdef MGL_STATIC_DEFINE" "#if 0")
endif()

# MathGL exports proper CMake config under the MathGL2Config.cmake filename, and
# a find_path/find_library based package under the mathgl2-config.cmake filename.
# The latter doesn't support multi-config or static linkage requirements, and
# the variable names don't match the package names, i.e. it is unusable.
if(VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE "${CURRENT_PACKAGES_DIR}/mathgl2-config.cmake")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/mathgl2-config.cmake")
else()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
endif()
vcpkg_cmake_config_fixup(PACKAGE_NAME mathgl2)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

set(tools mglconv mgltask)
if(enable-fltk)
    list(APPEND tools mglview mgllab)
endif()
if(enable-qt5)
    list(APPEND tools mglview udav)
endif()
list(REMOVE_DUPLICATES tools)
vcpkg_copy_tools(TOOL_NAMES ${tools} AUTO_CLEAN)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mgl2/config.h" "#define MGL_INSTALL_DIR	\"${CURRENT_PACKAGES_DIR}\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mgl2/config.h" "#define MGL_FONT_PATH\t\"${CURRENT_PACKAGES_DIR}/fonts\"" "") # there is no fonts folder
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mgl2/config.h" "#define MGL_FONT_PATH\t\"${CURRENT_PACKAGES_DIR}/share/mathgl/fonts\"" "")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
