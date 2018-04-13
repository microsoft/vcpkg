include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO skaslev/gl3w
  REF 8f7f459df8725c9614136b49a96023de276219f2
  SHA512 7674008716accb25347c81f755f2db7a885ecb5c51b481e0e8f337bc8ee0949a5a58f5816b27a66535ed4da0b9438ba6a6a84712560c7b1a0f1b2908b4eb81e5
  HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_download_distfile(
  GLCOREARB_H
  URLS "http://www.opengl.org/registry/api/GL/glcorearb.h"
  FILENAME "glcorearb-2018-02-27.h"
  SHA512 02c3672606e6360f2e1e8335fe581bc2d2b3d518b0f24b0c327006a70de07261dace4b53b13e93029a8eb2af43bcba904c4392f2c35ac512c7f278534ef8eb5d
)

file(INSTALL ${GLCOREARB_H} DESTINATION ${SOURCE_PATH}/include/GL RENAME glcorearb.h)

vcpkg_apply_patches(
  SOURCE_PATH ${SOURCE_PATH}
  PATCHES ${CMAKE_CURRENT_LIST_DIR}/0001-enable-shared-build.patch
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_execute_required_process(
  COMMAND ${PYTHON3} ${SOURCE_PATH}/gl3w_gen.py
  WORKING_DIRECTORY ${SOURCE_PATH}
  LOGNAME gl3w-gen
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/gl3w)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(HEADER ${CURRENT_PACKAGES_DIR}/include/GL/gl3w.h)
  file(READ ${HEADER} _contents)
  string(REPLACE "#define GL3W_API" "#define GL3W_API __declspec(dllimport)" _contents "${_contents}")
  file(WRITE ${HEADER} "${_contents}")
endif()

file(INSTALL ${SOURCE_PATH}/UNLICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/gl3w RENAME copyright)
