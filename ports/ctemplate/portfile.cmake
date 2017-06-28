include(vcpkg_common_functions)

set(GIT_REF 44b7c5b918a08ad561c63e9d28beecb40c10ebca)
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO OlafvdSpek/ctemplate
  REF 44b7c5b918a08ad561c63e9d28beecb40c10ebca
  SHA512 b572f6d0d182e977d3a459e68bde6244dad7196c44c16407990dc1fb6a7a93bcd8d6851e515d50b6051c1d011f71695f895f6ab233664baadae0bf6a3d464305
  HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_find_acquire_program(PYTHON2)

vcpkg_apply_patches(
  SOURCE_PATH ${SOURCE_PATH}
  PATCHES
  ${CMAKE_CURRENT_LIST_DIR}/fix-msvc.patch
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS -DPYTHON_EXECUTABLE=${PYTHON2}
  OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/ctemplate RENAME copyright)

vcpkg_copy_pdbs()
