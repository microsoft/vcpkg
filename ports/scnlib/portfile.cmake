vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eliaskosunen/scnlib
    REF "v${VERSION}"
    SHA512 5bca5a43dce9be019775a0cac64945c4b4cdadbecfa8d8e0889b6ed888c3a37ae757aa5d8d60d40418d0058641a40ab6dce35a1de84e9a9a2a6f5b4d12bceed4
    HEAD_REF master
    PATCHES
        fix-SCN_HAS_STD_REGEX_MULTILINE-marco.patch
        fix-android-float_reader.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DSCN_TESTS=OFF 
      -DSCN_EXAMPLES=OFF
      -DSCN_BENCHMARKS=OFF
      -DSCN_DOCS=OFF
      -DSCN_RANGES=OFF
      -DSCN_USE_EXTERNAL_SIMDUTF=ON
      -DSCN_USE_EXTERNAL_FAST_FLOAT=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/scn)

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/scn"
)

file(INSTALL "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright)
