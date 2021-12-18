if(VCPKG_TARGET_IS_WINDOWS)
  message(WARNING
    "You will need to also install https://raw.githubusercontent.com/unicode-org/cldr/master/common/supplemental/windowsZones.xml into your install location.\n"
    "See https://howardhinnant.github.io/date/tz.html"
  )
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO HowardHinnant/date
  REF v3.0.1
  SHA512 6BDC7CBA821D66E17A559250CC0CE0095808E9DB81CEC9E16EAA4C31ABDFA705299C67B72016D9B06B302BC306D063E83A374EB00728071B83A5AD650D59034F
  HEAD_REF master
  PATCHES
    0001-fix-uwp.patch
    0002-fix-cmake-3.14.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
    remote-api USE_SYSTEM_TZ_DB
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    ${FEATURE_OPTIONS}
    -DBUILD_TZ_LIB=ON
)

vcpkg_cmake_install()

if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_cmake_config_fixup(CONFIG_PATH CMake)
else()
  vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/date)
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
