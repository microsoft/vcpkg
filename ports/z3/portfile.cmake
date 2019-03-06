include(vcpkg_common_functions)

vcpkg_find_acquire_program(PYTHON2)
get_filename_component(PYTHON2_DIR "${PYTHON2}" DIRECTORY)
vcpkg_add_to_path("${PYTHON2_DIR}")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO Z3Prover/z3
  REF z3-4.8.4
  SHA512 4660ba6ab33a6345b2e8396c332d4afcfc73eda66ceb2595a39f152df4d62a9ea0f349b0f9212389ba84ecba6bdae6ad9b62b376ba44dc4d9c74f80d7a818bf4
  HEAD_REF master
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
)

vcpkg_build_cmake()


function(install_z3 SHORT_BUILDTYPE DEBUG_DIR)
  # copy libz3.dll/pdb
  file(GLOB DLLS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SHORT_BUILDTYPE}/libz3.[dp]*)
  file(INSTALL ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}${DEBUG_DIR}/bin)

  # copy libz3.so/lib
  file(GLOB LIBS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SHORT_BUILDTYPE}/libz3.[ls]*)
  file(INSTALL ${LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}${DEBUG_DIR}/lib)
endfunction()

if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
  install_z3("dbg" "/debug")
endif()
if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
  install_z3("rel" "")
endif()

file(GLOB HEADERS ${SOURCE_PATH}/src/api/z3*.h)
file(INSTALL ${HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/z3 RENAME copyright)
