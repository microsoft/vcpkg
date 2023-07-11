vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO sammycage/lunasvg
  REF 87137e791c912432b93982722a8e965628950ca7 #2.3.8
  SHA512 2914c70b3ba196a636f9860fbb7bd68d63aa59a1fe74c83c59f69bba189b117445285d84f6bcc53f55063999e25540d909dc44cb98c86710ea90e534370fa0ee
  HEAD_REF master
  PATCHES
    fix-install.patch
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DLUNASVG_BUILD_EXAMPLES=OFF
    -DBUILD_SHARED_LIBS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
