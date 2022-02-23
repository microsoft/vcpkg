vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jackaudio/jack2
    REF v1.9.19
    SHA512 d8d5fe17e2984959546af3c53f044aa4648860e19ff8ffd54452e87fa6cdfd111f825c57e3df17cb8ed95de8392b6f354b12ded41e3e021a37f07b99a89ba18d
    HEAD_REF master
)

# Install headers and a shim library with JackWeakAPI.c
file(COPY
  "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
  "${CMAKE_CURRENT_LIST_DIR}/jack.def"
  DESTINATION "${SOURCE_PATH}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/README.rst" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
