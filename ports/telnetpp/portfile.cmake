vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KazDragon/telnetpp
  REF f370ebd0c0dc6505708065ee5afdc59a6de54387 # v2.1.2 + MSVC patches
  SHA512 c58cb9159a8fb6c4b089a0212a995f70f08b93877d98828aa263e9f065f42a932d98749b56741d9e711c0805dcc2dcf0607dc86b0553c4e34bd3fad99e0bf157
  HEAD_REF master
  PATCHES fix-install-paths.patch
)

set(USE_ZLIB OFF)
if("zlib" IN_LIST FEATURES)
    set(USE_ZLIB ON)
endif()

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  DISABLE_PARALLEL_CONFIGURE
  PREFER_NINJA
  OPTIONS
    -DGSL_INCLUDE_PATH=${CURRENT_INSTALLED_DIR}/include
    -DTELNETPP_WITH_ZLIB=${USE_ZLIB}
    -DTELNETPP_WITH_TESTS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/telnetpp)

vcpkg_copy_pdbs()

# Remove duplicate header files and CMake input file
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/telnetpp/version.hpp.in)
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/telnetpp RENAME copyright)
