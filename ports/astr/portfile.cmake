vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO a4z/astr
  REF "${VERSION}"
  SHA512 528f851821e3bd0719881ed237b1720529a7c9141005214b1963565f164d1a6ec89adb1ea8efee0fa818ba9d8961afb4c7adfc91aca6308799d1ecbd8a9f2ab2
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
