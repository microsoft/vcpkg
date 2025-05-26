vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KazDragon/telnetpp
  REF "v${VERSION}"
  SHA512 0ff458675a44462655ff3869ff1c3390eec9d594a57a9ed95fb18f9b627b740b4f4be5e1fee3a5b9558553a05aae33134f8f8d26a85b8e4d2e01a927a8337c32
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
