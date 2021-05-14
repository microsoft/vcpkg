vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO client9/stringencoders
  REF e1448a9415f4ebf6f559c86718193ba067cbb99d
  SHA512 68c9b9a9eb09075c792cfc0a8ce1959c60a86e5256de8568b0cb6934f748fd9e95c5f1801a8982fecac65850a8f2d633a64dc98e4505ee8e6914bd0b0fb996cf
  HEAD_REF master
)

vcpkg_configure_cmake(
  SOURCE_PATH ${CMAKE_CURRENT_LIST_DIR}
  PREFER_NINJA
  OPTIONS -DSOURCE_PATH=${SOURCE_PATH}
  OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
