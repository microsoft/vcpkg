vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO soasis/text
  REF c07fba735ee8389d328103c10ce9a8d49f345060 
  SHA512 ca9ecacf3260f3915b7d2d90fb1d84f4083775043d592ac5d869a15debf5512d42488d43bd0d3d981180519359a423314e563f2065fa3effe2749904706f483a
  HEAD_REF main
  PATCHES fix-cmake-install.patch
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
