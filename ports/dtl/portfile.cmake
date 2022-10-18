#header-only library
include(CMakePackageConfigHelpers)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cubicdaiya/dtl
    REF v1.20
    SHA512 44cdaf190d8a103effbca8df244c652b642590795f7307f5f7fdf64fc34bdbe2fa5ab2e1a08185abf099e35b0d9158306a80a8dc24bba9eccab4c77c7b1eed5e
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/${PORT}"
  DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION
  "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
