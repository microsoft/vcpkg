vcpkg_minimum_required(VERSION 2022-10-12)
vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mathgl/mathgl
    REF "mathgl 8.0"
    FILENAME "mathgl-${VERSION}.tar.gz"
    SHA512 1ff3023f1bbd7bfd84202777a0166a8d4255a020a07f3650b9858929345bc8a2ceea4db155d2c93ba32b762d2304474276290a9edac99fda70fb4b5bc12982c2
    PATCHES
        cmake-config.patch
        dependencies.patch
        linkage.patch
        enable-examples.patch
        fix-examples.patch
        fix-cross-builds.patch
        fix-format-specifiers.patch
        fix-glut.patch
        fix-mgllab.patch
)
file(REMOVE_RECURSE "${SOURCE_PATH}/addons/getopt")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    arma    enable-arma
    examples enable-examples
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

if(VCPKG_TARGET_IS_OSX)
    list(APPEND FEATURE_OPTIONS
        -Denable-openmp=OFF
        -Denable-pthread=ON
    )
endif()

if(VCPKG_CROSSCOMPILING)
    list(APPEND FEATURE_OPTIONS "-DMAKE_BIN_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}/make_bin${VCPKG_HOST_EXECUTABLE_SUFFIX}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
        -DMathGL_INSTALL_CMAKE_DIR:STRING=share/mathgl2
        -DCMAKE_CXX_STANDARD=11 # minimum for armadillo on osx
        -DCMAKE_DISABLE_FIND_PACKAGE_Intl=1
        -DCMAKE_POLICY_DEFAULT_CMP0127=NEW # cmake_dependent_option condition syntax
)

vcpkg_cmake_install()

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

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/share/applications"
    "${CURRENT_PACKAGES_DIR}/share/mime"
    "${CURRENT_PACKAGES_DIR}/share/pixmaps"
)

set(tools mglconv mgltask)
if(NOT VCPKG_CROSSCOMPILING)
    list(APPEND tools make_bin)
endif()
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
