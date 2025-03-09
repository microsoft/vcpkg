set(VCPKG_POLICY_ALLOW_DEBUG_INCLUDE enabled)

vcpkg_from_github(
   OUT_SOURCE_PATH SOURCE_PATH
   REPO Darkx32/AudioEngine
   REF "${VERSION}"
   SHA512 66d3fd1beacafd7269cd548d4f3d06e5a13fb1aa44559105c20348d0e3e9592bffa45b7327d787a63ce18fd3b4d6b1aa56dfca9dd48dd0b7514e9856eaa8572e
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
       -DAUDIOENGINE_EXAMPLES=OFF
)

vcpkg_cmake_install()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
