vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO a4z/astr
  REF "${VERSION}"
  SHA512 4b730674d992efa94c3b4d290aeafc0b076fc6ca6033cc2aed90b92d77ff19498fb5af9fa83fa7b136d428e762518d9fb28bacf3965a9f4030f39e73aca89630
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
