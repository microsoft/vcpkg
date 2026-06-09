vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO efmsoft/logme
  REF "v${VERSION}"
  SHA512 dfc217b47eb415bf115bb9ee9fa0bb90b1e31461332f427bbee3bd41658a54be339b7f258f21bdd90c01896f8ec315038e9d48c5cbbb4a3432c64ec5a6521b7b
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
