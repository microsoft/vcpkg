vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KazDragon/telnetpp
  REF dec6d24c325a888f355c3e12b3a0f68ebe830a67
  SHA512 dd2f9725042df285428018da0303f89779c66bd7ddda74de2de0e2af6dcbea3136bd5ef784501ec4ca6ccef3a4fa7df0e6bd982238e5bad45f2afbe1c82382e0
  HEAD_REF master
  PATCHES 
      fix-install-paths-v3.patch
      fix_include.patch

)

set(USE_ZLIB OFF)
if("zlib" IN_LIST FEATURES)
    set(USE_ZLIB ON)
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  DISABLE_PARALLEL_CONFIGURE
  OPTIONS
    -DTELNETPP_WITH_ZLIB=${USE_ZLIB}
    -DTELNETPP_WITH_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/telnetpp)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/telnetpp-config.cmake" "####################################################################################" 
                    [[####################################################################################
                      include(CMakeFindDependencyMacro)
                      find_dependency(Boost)
                      find_dependency(gsl-lite)
                      find_dependency(ZLIB)]])
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE 
    "${CURRENT_PACKAGES_DIR}/include/telnetpp/version.hpp.in" 
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
