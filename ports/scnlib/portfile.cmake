include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eliaskosunen/scnlib
    REF 21001af7f21ddedc329a698d1a6514ee80a813ae
    SHA512 41a426fa94e1b2f31f5a1959ef97c59f48d0d7f0fd7369aab31a131aac71a173509e9354ef19e32211a1aba03597dbdfde131c8bb03fb234a093631716051d96
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
      -DCMAKE_DISABLE_FIND_PACKAGE_range-v3=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/scn)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/share/scn)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/scnlib RENAME copyright)


vcpkg_test_cmake(PACKAGE_NAME scn)
