if(VCPKG_TARGET_IS_WINDOWS)
  message(WARNING
    "You will need to also install https://raw.githubusercontent.com/unicode-org/cldr/master/common/supplemental/windowsZones.xml into your install location.\n"
    "See https://howardhinnant.github.io/date/tz.html"
  )
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO HowardHinnant/date
  REF "v${VERSION}"
  SHA512 e11d7f230ecc431d94c4b58fe7394dd57a9ec0baa9de52496578479b51bbf885566d6666882916d84d388060fa36065b3fa8dd3a8bc14f720b38d1c943f06700
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
