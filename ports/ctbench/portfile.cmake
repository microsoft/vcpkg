message(WARNING "Building ${PORT} requires a C++20 compliant compiler. GCC 12 and Clang 15 are known to work.")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jpenuchot/ctbench
    REF 7ddc634650f392923f0f511fb3b494a6e1add2a9
    SHA512 7acc45c383541fa2fc518585b1358e61103ae52c9e880df3d44b857489ea5c2d5fe004c810f60f3246f5d175d61ba80435e09ac1f2ce6a8a4dc63b8c1881f0f3
    HEAD_REF main
    PATCHES
        fix_build_with_boost_1_88_0.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DCTBENCH_ENABLE_TESTS=OFF
        -DCTBENCH_ENABLE_DOCS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ctbench
    TOOLS_PATH bin/)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
