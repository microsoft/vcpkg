# header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jamesdbrock/hffix
    REF "v${VERSION}"
    SHA512 a04a22360074f383997756d36ddf520a565e5d200e32e8439ef92f33bcb30ab29e962fc4d85142c1da323ddf9fef2d8b6a023dcbeedf1a5c269889adfcd70fb8
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/hffix")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)