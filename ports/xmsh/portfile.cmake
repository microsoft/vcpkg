include(vcpkg_common_functions)
vcpkg_find_acquire_program(PYTHON3)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO nagzira/xmsh
  REF v0.2.2
  SHA512 7d1810c78637b3ba2e546a69f4186bd9e7a6b3a58b78bcea1dab9a095a4f7b695ab8c0d27d1f977372bff196d1f55f285df2c6aa5ebd8fcbdc69046d819a2e1d
  HEAD_REF master
  )

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  )

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
vcpkg_copy_pdbs()
