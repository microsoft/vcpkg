# Download the code from GitHub
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO Arian8j2/ClipboardXX
  REF v${VERSION}
  SHA512 f5435698cf1c10609c22140974fc86c672a331c419e6c6faa94e9fdc14fb0b0dd59f1f16a062f18320d7c523ba1951d917ef607a307c1c3fa88c71ef8e34b4ca
  HEAD_REF master
  PATCHES
    fix-install.patch
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

configure_file(
  "${CMAKE_CURRENT_LIST_DIR}/unofficial-clipboardxx-config.cmake.in"
  "${CURRENT_PACKAGES_DIR}/share/unofficial-clipboardxx/unofficial-clipboardxx-config.cmake"
  @ONLY
)
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
