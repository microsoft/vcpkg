vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO sammycage/lunasvg
  REF e612abda858b53160041381a23422cd2b4f42fbd #2.3.1
  SHA512 44f5d013d918cb5af90114a12857bdd2c204caff761516ef98b12b08d8b6215e91f6d963c281500c386f287b9d0ecd5b3d986d4c8c33423c0c34d539d744e09d
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
