# Download the code from GitHub
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO Arian8j2/ClipboardXX
  REF d404c39ba384f8e16555610b3633cd7b58d84c59
  SHA512 503bc78cd9fd6096fa92524973d19cbc9169fca91450837a2af7f1518eb928dce10c01e446de1ab76ae0dc366b26831df403f021118fe5c3c2eaeb4d752f638f
  HEAD_REF master
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
