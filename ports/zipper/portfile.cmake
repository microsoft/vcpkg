vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO sebastiandev/zipper
  REF 201627bd3dbfbf1b53f69af29b8b079a9f3ffb1c
  SHA512 cd8362849a36945701e1f4b7305518b05e5d57df38fb578871182853e8757d582be839786387dac959c4b15f1a12172a5d870dd237a3e1361d8ec5dbcdb1616c
  HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/cmake DESTINATION ${SOURCE_PATH})

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Post-build test for cmake libraries
vcpkg_test_cmake(PACKAGE_NAME zipper)
