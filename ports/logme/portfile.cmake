vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO efmsoft/logme
  REF "v${VERSION}"
  SHA512 4debf121f997bddbd62e749b7cbc237142d9fd052cb7b2099d359cfb563cd43458ad452135dbe9eba1d37b8b139cf2f793ab61b379382b7e54a1a651fb50e793
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
