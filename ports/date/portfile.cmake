include(vcpkg_common_functions)

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  message(WARNING
    "You will need to also install https://raw.githubusercontent.com/unicode-org/cldr/master/common/supplemental/windowsZones.xml into your install location.\n"
    "See https://howardhinnant.github.io/date/tz.html"
  )
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO HowardHinnant/date
  REF 44344000f0fa32e66787d6d2c9ff5ddfd3605df7
  SHA512 1ec75a4b6310f735261c996c63df8176f0523d8f59a23edd49fd8efbdcbf1e78051ba2f36df0920f6f5e6bbc8f81ea4639f73e05bb1cb7f97a8e500bde667782
  HEAD_REF master
  PATCHES "${CMAKE_CURRENT_LIST_DIR}/0001-fix-uwp.patch"
)

set(DATE_USE_SYSTEM_TZ_DB 1)
if("remote-api" IN_LIST FEATURES)
  set(DATE_USE_SYSTEM_TZ_DB 0)
endif()

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DUSE_SYSTEM_TZ_DB=${DATE_USE_SYSTEM_TZ_DB}
    -DENABLE_DATE_TESTING=OFF
)

vcpkg_install_cmake()

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  vcpkg_fixup_cmake_targets(CONFIG_PATH CMake TARGET_PATH share/date)
else()
  vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/date TARGET_PATH share/date)
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/date RENAME copyright)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/date)

# Remove the wrapper when backwards compatibility with the unofficial::date::date and unofficial::date::tz
# targets is no longer required.
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/date)
