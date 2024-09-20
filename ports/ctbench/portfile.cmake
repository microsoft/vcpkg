message(WARNING "Building ${PORT} requires a C++20 compliant compiler. GCC 12 and Clang 15 are known to work.")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jpenuchot/ctbench
    REF "v${VERSION}"
    SHA512 862bfa72c4e98983fe8ac954de02b8f931c672ad3072ca84a0b9d527baa7572cafe235400d28e1f92b86154c9007d40cc2f034510ceda638e25c63625cb9cbf9
    HEAD_REF main
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
