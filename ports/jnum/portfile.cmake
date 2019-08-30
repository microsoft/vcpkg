include(vcpkg_common_functions)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO jayeshbadwaik/jnum
  HEAD_REF master
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DPYTHON3_EXECUTABLE=${PYTHON3}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

vcpkg_copy_pdbs()
