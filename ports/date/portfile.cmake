if(VCPKG_TARGET_IS_WINDOWS)
  message(WARNING
    "You will need to also install https://raw.githubusercontent.com/unicode-org/cldr/master/common/supplemental/windowsZones.xml into your install location.\n"
    "See https://howardhinnant.github.io/date/tz.html"
  )
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO HowardHinnant/date
  REF c05cd34119d62f96deed28c803d2fd0b59548d8f
  SHA512 b756494d97c719d947ba79db478811c17b1aea4dc8e32efc8eba73b7feebe05b02d3042af91fe2134360a9d5b0ae6c320ef008134d1ace55af03e6a973d6bd77
  HEAD_REF master
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
  vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/date")
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
