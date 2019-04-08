include(vcpkg_common_functions)

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  message(WARNING
    "You will need to also install http://unicode.org/repos/cldr/trunk/common/supplemental/windowsZones.xml into your install location.\n"
    "See https://howardhinnant.github.io/date/tz.html"
  )
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO HowardHinnant/date
  REF 9dc96fd9b5e4e1e7885aa80dc24a3ceb407c3730
  SHA512 1acb78f1ae7f5b1278a9e034fa5ccbb64643ad381ef9bd76bf42fb04d714c6742f2129b6892024cd98bb925e1a6136337fccb636e3f991b428be1ed05ab8901e
  HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

set(HAS_REMOTE_API 0)
if("remote-api" IN_LIST FEATURES)
  set(HAS_REMOTE_API 1)
endif()

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS -DHAS_REMOTE_API=${HAS_REMOTE_API}
  OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-date TARGET_PATH share/unofficial-date)

vcpkg_copy_pdbs()

set(HEADER "${CURRENT_PACKAGES_DIR}/include/date/tz.h")
file(READ "${HEADER}" _contents)
string(REPLACE "#define TZ_H" "#define TZ_H\n#undef HAS_REMOTE_API\n#define HAS_REMOTE_API ${HAS_REMOTE_API}" _contents "${_contents}")
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  string(REPLACE "ifdef DATE_BUILD_DLL" "if 1" _contents "${_contents}")
endif()
file(WRITE "${HEADER}" "${_contents}")

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/date RENAME copyright)
