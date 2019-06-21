include(vcpkg_common_functions)

set(MATHGL_VERSION "2.4.3")
vcpkg_download_distfile(ARCHIVE
  URLS "https://downloads.sourceforge.net/project/mathgl/mathgl/mathgl%20${MATHGL_VERSION}/mathgl-${MATHGL_VERSION}.tar.gz"
  FILENAME "mathgl-${MATHGL_VERSION}.tar.gz"
  SHA512 e47fc8171ce80c8b33a8f03d9375bc036455dae539b47cf4ee922f8fa36f5afcf8b3f0666997764e453eb698c0e8c03da36dd0ac2bf71c158e95309b247d27de
)

vcpkg_extract_source_archive_ex(
  OUT_SOURCE_PATH SOURCE_PATH
  ARCHIVE ${ARCHIVE}
  REF ${MATHGL_VERSION}
  PATCHES
    type_fix.patch
)

set(enable-hdf5 OFF)
if("hdf5" IN_LIST FEATURES)
  set(enable-hdf5 ON)
endif()

set(enable-fltk OFF)
if("fltk" IN_LIST FEATURES)
  set(enable-fltk ON)
endif()

set(enable-gif OFF)
if("gif" IN_LIST FEATURES)
  set(enable-gif ON)
endif()

set(enable-png OFF)
if("png" IN_LIST FEATURES)
  set(enable-png ON)
endif()

set(enable-zlib OFF)
if("zlib" IN_LIST FEATURES)
  set(enable-zlib ON)
endif()

set(enable-jpeg OFF)
if("jpeg" IN_LIST FEATURES)
  set(enable-jpeg ON)
endif()

set(enable-gsl OFF)
if("gsl" IN_LIST FEATURES)
  set(enable-gsl ON)
endif()

set(enable-opengl OFF)
if("opengl" IN_LIST FEATURES)
  set(enable-opengl ON)
endif()

set(enable-glut OFF)
if("glut" IN_LIST FEATURES)
  set(enable-glut ON)
endif()

set(enable-wx OFF)
if("wx" IN_LIST FEATURES)
  set(enable-wx ON)
endif()

set(enable-qt5 OFF)
if("qt5" IN_LIST FEATURES)
  set(enable-qt5 ON)
endif()

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
   -Denable-hdf5=${enable-hdf5}
   -Denable-fltk=${enable-fltk}
   -Denable-gif=${enable-gif}
   -Denable-png=${enable-png}
   -Denable-zlib=${enable-zlib}
   -Denable-jpeg=${enable-jpeg}
   -Denable-gsl=${enable-gsl}
   -Denable-opengl=${enable-opengl}
   -Denable-glut=${enable-glut}
   -Denable-wx=${enable-wx}
   -Denable-qt5=${enable-qt5}
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

file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/mglconv${EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/mgltask${EXECUTABLE_SUFFIX})
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/mathgl/)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/mglconv${EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/mathgl/mglconv${EXECUTABLE_SUFFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/mgltask${EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/mathgl/mgltask${EXECUTABLE_SUFFIX})
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/mathgl)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/mathgl RENAME copyright)
