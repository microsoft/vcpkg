vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ros/urdfdom_headers
    REF "${VERSION}"
    SHA512 b0eed4da4d1f165ab33812c181000fa58f3d817703a0b8728a9d4b9f888eeed15d095072c16eb5779850e8a88984633345b444396c58bd79bedf7bf3eb6e16bc
    HEAD_REF master
    PATCHES fix-include-path.patch
  )

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

if(EXISTS "${CURRENT_PACKAGES_DIR}/CMake")
    vcpkg_cmake_config_fixup(CONFIG_PATH CMake PACKAGE_NAME urdfdom_headers)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/urdfdom_headers/cmake PACKAGE_NAME urdfdom_headers)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/urdfdom_headers")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/urdfdom_headers")
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
