set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tclap
    FILENAME "tclap-1.2.5.tar.gz"
    SHA512 3b5b3d76e8ff21133001f5f9589fa6ec143729909bf0b9cc9934377bce178360c161fb5c1f4c4d9e9c74b09cff3d65f1d5100e61d4a732283524a78b6f236b10
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
     DESTINATION "${SOURCE_PATH}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/tclap")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
