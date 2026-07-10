vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO efmsoft/logme
  REF "v${VERSION}"
  SHA512 5563c8e5821094e7deb4f508b6666386a760c3ce477a8d6125e21e45d48b0e624d11fe5556add698f2480e78b97285a2b99273240510843d9627bfbb7ef66a11
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
    -DUSE_ZLIB=OFF
    -DLOGME_FMT_FORMAT=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/logme)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/Logme/Json")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/Logme/Types.h" "!defined(_LOGME_STATIC_BUILD_)" "1")
else()
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/Logme/Types.h" "!defined(_LOGME_STATIC_BUILD_)" "0")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
