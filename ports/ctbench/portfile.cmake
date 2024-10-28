message(WARNING "Building ${PORT} requires a C++20 compliant compiler. GCC 12 and Clang 15 are known to work.")

vcpkg_download_distfile(
    BOOST_1_86_FIX
    URLS https://github.com/JPenuchot/ctbench/commit/d61e61c6e6693c768f728c58bfbe3f07e404b9f7.patch?full_index=1
    FILENAME ctbench-boost-1-86-fix-d61e61c6e6693c768f728c58bfbe3f07e404b9f7.patch
    SHA512 cbcba17cf71977b188456ca4abb5044d7ec99ac7fb511bf29e5a4f2fb8f1be13682f23c256f7c03e83e6e77ed0905c3b02d384bff5f9b36d3c059b2219b09b94
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jpenuchot/ctbench
    REF "v${VERSION}"
    SHA512 862bfa72c4e98983fe8ac954de02b8f931c672ad3072ca84a0b9d527baa7572cafe235400d28e1f92b86154c9007d40cc2f034510ceda638e25c63625cb9cbf9
    HEAD_REF main
    PATCHES
        "${BOOST_1_86_FIX}"
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
