vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eliaskosunen/scnlib
    REF "v${VERSION}"
    SHA512 12b9ae26a5ccc600aacad1e2b2287bfc0b6986a260e182c91541876bc5804fe661093ad10d1befda56803afc7a9aa9f0348820dbb5af4fa6fdf048f85b3bcef1
    HEAD_REF master
    PATCHES
        fix-SCN_HAS_STD_REGEX_MULTILINE-marco.patch
        remove-simdutf-dependency-version.patch
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
