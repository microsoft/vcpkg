vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jackaudio/jack2
    REF "v${VERSION}"
    SHA512 d93cb2bcc57b72b6815eed143de1092d14fe22542ae9a1f8480d9ed5f44b59c50f81279d18bdd84ff6276ddd71ca1aa64a1e46d61199a5eda0d873a356194ab4
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
