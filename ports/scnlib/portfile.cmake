vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eliaskosunen/scnlib
    REF "v${VERSION}"
    SHA512 76f3196d6bd01a349c69bf1863cc0dc521a95b84ef25b841198acbef99e295b53c1c82c745a7498b9a86a6fd4cc0c395abcb02fdf18b1d7c9152321ab195945b
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DSCN_TESTS=OFF
      -DSCN_EXAMPLES=OFF
      -DSCN_BENCHMARKS=OFF
      -DSCN_DOCS=OFF
      -DSCN_USE_EXTERNAL_FAST_FLOAT=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/scn)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/scn"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
