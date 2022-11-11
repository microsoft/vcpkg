vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jackaudio/jack2
    REF v1.9.21
    SHA512 0e9ce581fca3c5d9ffb1de22b45cae6d94085c6f92ff3554892e25727baf66a2269f10d338d95d991e8380c4be5e0cc1e1453b9f878c7dc2e8a990f3bd458557
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

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
