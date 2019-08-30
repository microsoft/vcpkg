include(vcpkg_common_functions)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO jayeshbadwaik/jnum
  REF HEAD
  SHA512 7766aebf6b82792abbf021ebead15ca7d43b0bc6bc5d3ccf97e1005deb64f965b96821296c2abc7e46c3bcdc3fe27111cab235f45ea2a0d2287dc5c9508efbba
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
