include(vcpkg_common_functions)
vcpkg_find_acquire_program(PYTHON3)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO nagzira/xmsh
  REF v0.4
  SHA512 1c0f30afa29e32fbb7e716c376d37fc6858468fd592f2d63af59b6f85052773cf830cae72ed4e82a0e7d700f8d5e0c827da8296297691579bf8bf4047cb61e66
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
