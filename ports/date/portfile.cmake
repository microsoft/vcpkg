include(vcpkg_common_functions)

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  message(WARNING
    "You will need to also install https://raw.githubusercontent.com/unicode-org/cldr/master/common/supplemental/windowsZones.xml into your install location.\n"
    "See https://howardhinnant.github.io/date/tz.html"
  )
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KomodoPlatform/date
  REF 3e376be2e9b4d32c946bd83c22601e4b7a1ce421
  SHA512 9dad181f8544bfcff8c42200552b6673e537c53b34fbad11663d6435d4e5fd5a3ac6cabbb76312481c9784b237151d9ccd161bb1b8c54c563fa75073896f3cff
  HEAD_REF master
  PATCHES
    "${CMAKE_CURRENT_LIST_DIR}/0001-fix-uwp.patch"
    "${CMAKE_CURRENT_LIST_DIR}/0002-fix-cmake-3.14.patch"
)

set(DATE_USE_SYSTEM_TZ_DB 1)
if("remote-api" IN_LIST FEATURES)
  set(DATE_USE_SYSTEM_TZ_DB 0)
endif()

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DBUILD_TZ_LIB=ON
    -DUSE_SYSTEM_TZ_DB=${DATE_USE_SYSTEM_TZ_DB}
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

# Remove the wrapper when backwards compatibility when the unofficial::date::date and unofficial::date::tz
# targets are no longer required.
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/date)
