include(vcpkg_common_functions)
vcpkg_find_acquire_program(PYTHON3)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO nagzira/xmsh
  REF v0.2.3
  SHA512 8a93e41e5b83db637d44e4e2a33d2f7c4ddd751d5ff454b032307b4795e453743dea02eb89c793f9b0a938787f56dad8b5da013a7fd8fe93771bf171a8f47768
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
