vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KazDragon/telnetpp
  REF "v${VERSION}"
  SHA512 be0a4304846369f85fef68c9b468b720877a640f8fb32496cf56591da4bb515b9afa9ac4c4477b2275049c304bd17c84b8b82efd8af642c509df452fec9d0d8e
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
