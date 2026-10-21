vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KazDragon/telnetpp
  REF "v${VERSION}"
  SHA512 71046b8831a9e48d01cec61ed854ee703e042e33b4b1c8c15afaf7b7f0b74da581d7a2eff4c906a5d2ffae7f84798f94cc4e39a7cc53aa534b4690ef95569757
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
