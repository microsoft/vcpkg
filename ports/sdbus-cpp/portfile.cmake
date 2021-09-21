vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Kistler-Group/sdbus-cpp
    REF v0.8.3
    HEAD_REF master
    SHA512 bdaccd686aeba9f24284c796fac7d0b6d514365e0b757db91e209e1e15c928d9de8ab1d5f5d21671896b07ea762ab4b7c6a5ce0850b17ad08bacb0f1a668cfb2 
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      "-D BUILD_TESTS=OFF"
      "-D BUILD_DOC=OFF"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/sdbus-c++)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")


# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
