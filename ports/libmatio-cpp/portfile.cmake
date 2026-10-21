vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ami-iit/matio-cpp
    REF "v${VERSION}"
    SHA512 efae9cec18b44291625f0770dabe8fd23c5b1d7cf77849cab827880ca96328430d4146014ace82d443bbc00cc313fd23cd5d67a7f1b58235efa7b5cb291a8ea4
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/matioCppConfig.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME matioCpp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
