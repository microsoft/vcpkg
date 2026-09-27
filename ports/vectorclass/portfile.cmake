vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vectorclass/version2
    REF v${VERSION}
    SHA512 3cc4074a316d4fc0a541c7ba90f759573e74472cce70caaf6204f2c5c47f48e76f2d609de67e4819016a49f40004c3088a6a7c48a432455f80e4735725815638
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Put the licence file where vcpkg expects it
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
