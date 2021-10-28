vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eliaskosunen/scnlib
    REF v0.4
    SHA512 a7059e70326e7d5af463b4ae09308644f8035092776f44001c1a4abf78421f55084e2fc30c6a9778eda62014354dba7c31b3f2f2d333bad04a2ec48b1f812ca0
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
      -DSCN_TESTS=OFF 
      -DSCN_EXAMPLES=OFF
      -DSCN_BENCHMARKS=OFF
      -DSCN_DOCS=OFF
      -DSCN_RANGES=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/scn)

file(REMOVE_RECURSE 
    ${CURRENT_PACKAGES_DIR}/debug/include 
    ${CURRENT_PACKAGES_DIR}/debug/share 
    ${CURRENT_PACKAGES_DIR}/share/scn)

file(INSTALL ${SOURCE_PATH}/LICENSE 
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright)
