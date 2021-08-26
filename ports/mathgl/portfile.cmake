set(MATHGL_VERSION "2.4.3")

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mathgl/mathgl
    REF mathgl%20${MATHGL_VERSION}
    FILENAME "mathgl-${MATHGL_VERSION}.tar.gz"
    SHA512 e47fc8171ce80c8b33a8f03d9375bc036455dae539b47cf4ee922f8fa36f5afcf8b3f0666997764e453eb698c0e8c03da36dd0ac2bf71c158e95309b247d27de
    PATCHES
        type_fix.patch
        fix_cmakelists_and_cpp.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    hdf5    enable-hdf5
    fltk    enable-fltk
    gif     enable-gif
    png     enable-png
    zlib    enable-zlib
    jpeg    enable-jpeg
    gsl     enable-gsl
    opengl  enable-opengl
    glut    enable-glut
    wx      enable-wx
    qt5     enable-qt5
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/mathgl2-config.cmake)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/mathgl2-config.cmake)
else()
  vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/mathgl)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

#somehow the native CMAKE_EXECUTABLE_SUFFIX does not work, so here we emulate it
if(CMAKE_HOST_WIN32)
  set(EXECUTABLE_SUFFIX ".exe")
else()
  set(EXECUTABLE_SUFFIX "")
endif()

file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/mgllab${EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/mglview${EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/mglconv${EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/mgltask${EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/udav${EXECUTABLE_SUFFIX})
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/mathgl/)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/mglconv${EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/mathgl/mglconv${EXECUTABLE_SUFFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/mgltask${EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/mathgl/mgltask${EXECUTABLE_SUFFIX})
if (EXISTS ${CURRENT_PACKAGES_DIR}/bin/mgllab${EXECUTABLE_SUFFIX})
	file(RENAME ${CURRENT_PACKAGES_DIR}/bin/mgllab${EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/mathgl/mgllab${EXECUTABLE_SUFFIX})
endif()
if (EXISTS ${CURRENT_PACKAGES_DIR}/bin/mglview${EXECUTABLE_SUFFIX})
	file(RENAME ${CURRENT_PACKAGES_DIR}/bin/mglview${EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/mathgl/mglview${EXECUTABLE_SUFFIX})
endif()
if (EXISTS ${CURRENT_PACKAGES_DIR}/bin/udav${EXECUTABLE_SUFFIX})
	file(RENAME ${CURRENT_PACKAGES_DIR}/bin/udav${EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/mathgl/udav${EXECUTABLE_SUFFIX})
endif()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/mathgl)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/mathgl RENAME copyright)
