set(MATHGL_VERSION "2.5")

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mathgl/mathgl
    REF mathgl%20${MATHGL_VERSION}
    FILENAME "mathgl-${MATHGL_VERSION}.tar.gz"
    SHA512 1fe27962ffef8d7127c4e1294d735e5da4dd2d647397f09705c3ca860f90bd06fd447ff614e584f3d2b874a02262c5518be37d59e9e0a838dd5b8b64fd77ef9d
    PATCHES
        fix_cmakelists_and_cpp.patch
        fix_attribute.patch
        fix_default_graph_init.patch
        fix_mglDataList.patch
        fix_arma_sprintf.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    hdf5    enable-hdf5
    fltk    enable-fltk
    gif     enable-gif
    arma    enable-arma
    png     enable-png
    zlib    enable-zlib
    jpeg    enable-jpeg
    gsl     enable-gsl
    opengl  enable-opengl
    glut    enable-glut
    wx      enable-wx
    qt5     enable-qt5
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
  file(REMOVE "${CURRENT_PACKAGES_DIR}/mathgl2-config.cmake")
  file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/mathgl2-config.cmake")
else()
  vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/mathgl2)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

#somehow the native CMAKE_EXECUTABLE_SUFFIX does not work, so here we emulate it
if(CMAKE_HOST_WIN32)
  set(EXECUTABLE_SUFFIX ".exe")
else()
  set(EXECUTABLE_SUFFIX "")
endif()

file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/mgllab${EXECUTABLE_SUFFIX}")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/mglview${EXECUTABLE_SUFFIX}")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/mglconv${EXECUTABLE_SUFFIX}")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/mgltask${EXECUTABLE_SUFFIX}")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/udav${EXECUTABLE_SUFFIX}")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/mathgl/")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin/mglconv${EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/mathgl/mglconv${EXECUTABLE_SUFFIX}")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin/mgltask${EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/mathgl/mgltask${EXECUTABLE_SUFFIX}")
if (EXISTS "${CURRENT_PACKAGES_DIR}/bin/mgllab${EXECUTABLE_SUFFIX}")
	file(RENAME "${CURRENT_PACKAGES_DIR}/bin/mgllab${EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/mathgl/mgllab${EXECUTABLE_SUFFIX}")
endif()
if ("EXISTS ${CURRENT_PACKAGES_DIR}/bin/mglview${EXECUTABLE_SUFFIX}")
	file(RENAME "${CURRENT_PACKAGES_DIR}/bin/mglview${EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/mathgl/mglview${EXECUTABLE_SUFFIX}")
endif()
if (EXISTS "${CURRENT_PACKAGES_DIR}/bin/udav${EXECUTABLE_SUFFIX}")
	file(RENAME "${CURRENT_PACKAGES_DIR}/bin/udav${EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/mathgl/udav${EXECUTABLE_SUFFIX}")
endif()

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/mathgl")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mgl2/config.h" "#define MGL_INSTALL_DIR	\"${CURRENT_PACKAGES_DIR}\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mgl2/config.h" "#define MGL_FONT_PATH	\"${CURRENT_PACKAGES_DIR}/fonts\"" "") # there is no fonts folder

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/mathgl" RENAME copyright)
