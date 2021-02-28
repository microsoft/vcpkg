#header-only library
include(CMakePackageConfigHelpers)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cubicdaiya/dtl
    REF v1.19
    SHA512 77c767451b1b78ce49085da6ff5bb8a23c96dec56a37d96ef357a6b69a1b2cd45e2c6c4e8f91ee34ca080ce03a26518c478ff207309326a4bc7e729eaa2824b2
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/dtl
  DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION
  ${CURRENT_PACKAGES_DIR}/share/dtl RENAME copyright)
