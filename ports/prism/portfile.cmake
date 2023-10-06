#vcpkg_from_git(
#    OUT_SOURCE_PATH SOURCE_PATH
#    URL https://github.com/nocanstillbb/prism.git
#    REF 59fc49ca76338364c6351475a4ad5d80578f625
#)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO nocanstillbb/prism
    REF b9a1ce36948a02058be3bd57d64953bc6cfabf3e
  SHA512 12b26fa97cfbf0227a7dc057f100ff79df23880d1522aeed02e939fb6c9afccb092a264d78c08702dfb7cc30701d4ea48d9bdea29168be5751c8965e2011fb0d
  HEAD_REF master
)


#https://learn.microsoft.com/en-us/vcpkg/examples/packaging-github-repos
vcpkg_cmake_configure( SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

#vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
#vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright)
file(
  INSTALL "${SOURCE_PATH}/usage"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

#execute_process(COMMAND ${CMAKE_COMMAND} -E echo "
#----------
##----------" )

