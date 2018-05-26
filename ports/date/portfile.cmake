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
  REF v2.4.1
  SHA512 ce7d1c4518558d3690b3a33cd3da1066b43a5f641282c331c60be73e9b010227d4998bca5f34694215ae52f6514a2f5eccd6b0a5ee3dcf8cef2f2d1644c8beee
  HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/fix-date.patch
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
