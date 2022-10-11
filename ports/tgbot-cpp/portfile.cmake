vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO reo7sp/tgbot-cpp
  REF v1.3
  SHA512 1b992c7705a5f7bb081df3eb032feb78b2b5eb2e73a7be822cd12552702a4d18ac9eecbd0c842f2d6c48757e91d3f8ceb5965237264b9ec18657e51c3bde7f79
  HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
