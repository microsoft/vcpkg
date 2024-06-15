vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO reo7sp/tgbot-cpp
  REF v1.8
  SHA512 b43eaadefb7631e7c1619e0290fe92917536be632614c9e9f048119b4c9eb9cf4d72e2db1c4ffdaa1d6a43deedc66dfa73d8670ba119e2fa67266310c233bb32
  HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/LICENSE)
