if(VCPKG_TARGET_IS_WINDOWS)
  message(WARNING
    "You will need to also install https://raw.githubusercontent.com/unicode-org/cldr/master/common/supplemental/windowsZones.xml into your install location.\n"
    "See https://howardhinnant.github.io/date/tz.html"
  )
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO HowardHinnant/date
  REF cac99da8dc88be719a728dc1b597b0ac307c1800 #3.0.0
  SHA512 07bac40c9d92ed92f05ab71b07c203fc341cd35999f1eab16d584bf77ff69e2cdc106931b2faf0dcfc5a311ee55e8445a81fd97c62f4672957b6aac1b24a08fd
  HEAD_REF master
  PATCHES
    0001-fix-uwp.patch
    0002-fix-cmake-3.14.patch
    0003-find-dependency-pthread.patch
)
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
    remote-api USE_SYSTEM_TZ_DB
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
     ${FEATURE_OPTIONS}
    -DBUILD_TZ_LIB=ON
)

vcpkg_install_cmake()

if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_fixup_cmake_targets(CONFIG_PATH CMake TARGET_PATH share/date)
else()
  vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/date TARGET_PATH share/date)
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/date RENAME copyright)
