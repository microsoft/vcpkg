include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO OlafvdSpek/ctemplate
  REF 4b7e6c52dc7cbb4d51c9abcebcbac91ec256a62b
  SHA512 9317fb26f22892b0bc2ca17cbccb5b084091050aa88766b4ed673a690bc4cdb9cd882134fbcd7ed3ee156f6a6937218717765143796d7e98b532355867ed042b
  HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_find_acquire_program(PYTHON3)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS -DPYTHON_EXECUTABLE=${PYTHON3}
  OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/ctemplate RENAME copyright)

vcpkg_copy_pdbs()
