vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO efmsoft/logme
  REF "v${VERSION}"
  SHA512 7afb4452cc1c7a38cca0b2b951d2828f16d6fdacb456284d5896281f915bd9170f1667df443f9ce49c7f4f5dc790498215a14cc8196085ac3254378c12a924c5
  HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}"  "static" _logme_static_opt)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}"  "dynamic" _logme_dynamic_opt)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DLOGME_BUILD_STATIC=${_logme_static_opt}
    -DLOGME_BUILD_DYNAMIC=${_logme_dynamic_opt}
    -DLOGME_BUILD_TESTS=OFF
    -DLOGME_BUILD_EXAMPLES=OFF
    -DLOGME_BUILD_TOOLS=OFF
    -DUSE_JSONCPP=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/logme)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
