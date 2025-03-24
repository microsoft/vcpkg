
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ami-iit/matio-cpp
    REF "${VERSION}"
    SHA512 efae9cec18b44291625f0770dabe8fd23c5b1d7cf77849cab827880ca96328430d4146014ace82d443bbc00cc313fd23cd5d67a7f1b58235efa7b5cb291a8ea4
    HEAD_REF master
    PATCHES
    fix-dependencies.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/matioCppConfig.cmake.in" DESTINATION "${SOURCE_PATH}")
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "matioCpp"
CONFIG_PATH share/matioCpp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
