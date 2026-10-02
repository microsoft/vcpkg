vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bombela/backward-cpp
    REF 0bfd0a07a61551413ccd2ab9a9099af3bad40681 # 2025-04-14
    SHA512 74694547b788145249effb7fee1ef2760f02c736f0e2cb6710f9304bd530c52675acb8e3b717d40049b8163381df0d84675065722e641eedcaa3f5777c8e6b09
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
