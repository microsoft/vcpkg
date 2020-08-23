vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eliaskosunen/scnlib
    REF v0.3
    SHA512 91ab0ff5d7d2e4a4924bfa00cafc49c3b0d88b87f4adbdce786be0f51913e3c61c6948c27da6af1e020646e610540dc63323fbf7b59f9210266f1ba79bf95adc
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

vcpkg_test_cmake(PACKAGE_NAME scn)
