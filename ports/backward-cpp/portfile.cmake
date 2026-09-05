vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bombela/backward-cpp
    REF 51f0700452cf71c57d43c2d028277b24cde32502 # 2023-11-24
    SHA512 8831be0a1c0a2f2d2625c5e2065202445520e0f7591cdbf998c60f2c892880d1527f304f9361b057c831f84621be636e12fea018297c9a17d858ecc6c36c9ffb
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DBACKWARD_TESTS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/backward)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
