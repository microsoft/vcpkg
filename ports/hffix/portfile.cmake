# header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jamesdbrock/hffix
    REF v1.2.1
    SHA512 81947d5b2fbc2818b6ae7274febece8a813a67afc4a605bd92a1d7cb5df4e19e5df73a1a597c27898134fab1a0cc7c672d2dcba7688bab24184469b0760be06f
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