#header-only library
include(CMakePackageConfigHelpers)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cubicdaiya/dtl
    REF "v${VERSION}"
    SHA512 53a448ce499d96c5030ff787db68dd4cb52ee9686453da81aeb5c143e21d4a10fcc4c9b88ebf86d71824cb919d6e4ebf39df52b74bd9333f411935e5f23bfa86
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/${PORT}"
  DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION
  "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
