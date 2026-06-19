vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO a4z/astr
  REF "v${VERSION}"
  SHA512 795f63ceb98959e19285edbb0480a8c5ea8ba3e9129c44738289b53c05a13356e9971263cfbcd89405a4fed6127998a70a0119989d7bcf3c8c69b5503cf6e90f
  HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
      -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
