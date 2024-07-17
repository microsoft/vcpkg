vcpkg_from_github(
  OUT_SOURCE_PATH ZTD_CMAKE_SOURCE_PATH
  REPO soasis/cmake
  REF c29df2f0b006f8b24214ccea0a7e2f8fbbe135ce
  SHA512 5dda06c1ba6422eb0d4392dee962e731505ec93ac90de0129a8b8519e376cc53e24177791e7fed373ca1b3f4377b450a65922ad37b612f29330e6f81d65ff463
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO soasis/text
  REF c07fba735ee8389d328103c10ce9a8d49f345060 
  SHA512 ca9ecacf3260f3915b7d2d90fb1d84f4083775043d592ac5d869a15debf5512d42488d43bd0d3d981180519359a423314e563f2065fa3effe2749904706f483a
  HEAD_REF main
  PATCHES
    fix-cmake-install.patch
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    # See https://github.com/soasis/cmake/blob/c29df2f0b006f8b24214ccea0a7e2f8fbbe135ce/CMakeLists.txt#L43
    "-DZTD_CMAKE_PACKAGES=${ZTD_CMAKE_SOURCE_PATH}/Packages"
    "-DZTD_CMAKE_MODULES=${ZTD_CMAKE_SOURCE_PATH}/Modules"
    "-DZTD_CMAKE_PROJECT_PRELUDE=${ZTD_CMAKE_SOURCE_PATH}/Includes/Project.cmake"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
