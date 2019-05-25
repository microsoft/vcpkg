include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH CMAKE_SOURCE_PATH
  REPO noloader/cryptopp-cmake
  REF 8acc7fdd5face650c299d998cd5e312e6b6e2795
  SHA512 79d3f023f67009533a97c64a5142f75596b57784df3c8d7f34b9ede535b8da487f51f2e47df4e43d89063d05e75ee03d47ea575fa93e12b4456ae79b816a7993
  HEAD_REF master
  PATCHES
    cmake.patch
    simon-speck.patch
    missing-flags.patch
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO weidai11/cryptopp
  REF CRYPTOPP_8_1_0
  SHA512 2b09b30c53a8f95a9c3204a48867174c70a1e97171854122f4d8454b25d5af9b94cab2c210dd9857c7db66df881849183e82b6155b80bfef6e69dac8efd2ea9a
  HEAD_REF master
  PATCHES patch.patch
)

file(COPY ${CMAKE_SOURCE_PATH}/cryptopp-config.cmake DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_SOURCE_PATH}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

# Dynamic linking should be avoided for Crypto++ to reduce the attack surface,
# so generate a static lib for both dynamic and static vcpkg targets.
# See also:
#   https://www.cryptopp.com/wiki/Visual_Studio#Dynamic_Runtime_Linking
#   https://www.cryptopp.com/wiki/Visual_Studio#The_DLL

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_SHARED=OFF
        -DBUILD_STATIC=ON
        -DBUILD_TESTING=OFF
        -DBUILD_DOCUMENTATION=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/cryptopp)

# There is no way to suppress installation of the headers and resource files in debug build.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/cryptopp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cryptopp/License.txt ${CURRENT_PACKAGES_DIR}/share/cryptopp/copyright)
