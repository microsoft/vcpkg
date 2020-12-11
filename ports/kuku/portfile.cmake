vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/Kuku
    REF e7cd2d6ad7f8886061c8e4b85890ede69cec3929
    SHA512 8220a8e839bd247d6a8d1049562028c620353d0cabee0681383d1457bda544ff1394709eeaa82a92a8c0d3491cc9f15de1a14b78a86e8f97ee1da68eb50c982e
    HEAD_REF master
    PATCHES CMakeLists-windows.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Kuku-2.0)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
