vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO dankamongmen/notcurses
  REF v2.3.7
  SHA512 a5563c2bf13ccefb6e08140bf63b03ba1a9e0cfa628e31e5b2a1d0d069ea9f88038a903f3fbebf2e037de969a47443b97912669656ade3024bac300799ce7e79
  HEAD_REF master
)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" NOTCURSES_BUILD_STATIC)
vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DUSE_STATIC=${NOTCURSES_BUILD_STATIC}
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PROCESS_DIR}/share/notcurses RENAME copyright)
