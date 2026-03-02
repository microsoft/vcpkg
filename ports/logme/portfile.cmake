vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO efmsoft/logme
  REF "v${VERSION}"
  SHA512 5de1c3be1f1e43c9815acc29959dbee6478dda0ac0824228bdd25f65dd2ff1f3a997f039253644219c6c7afdd29576d1510b7b0c1226f5d6184bd170d7a49186
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
