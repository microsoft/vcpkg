vcpkg_from_github(
    REPO c4dm/vamp-plugin-sdk
    REF vamp-plugin-sdk-v2.10
    SHA512 67a71e5396eab5ce9503e9111b4cfc16fc9755cf6ae2d8dfc99ed29fd91e75eaf0de9a9c55ce8f7751f04c235eb86430856eff18f02adde54f1850a87c917ef0
    OUT_SOURCE_PATH SOURCE_PATH
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# # Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
