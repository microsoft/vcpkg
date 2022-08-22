vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH CMAKE_SOURCE_PATH
  REPO noloader/cryptopp-cmake
  REF CRYPTOPP_8_6_0
  SHA512 655107b8a41e1e6603a6b3ed2ddc95fad22b646c071c7251c3c7e2151afe439de848679235a3790fe540263424324f06c922687719da6dfea341bc2a75337bdc
  HEAD_REF master
  PATCHES
    cmake.patch
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO weidai11/cryptopp
  REF CRYPTOPP_8_6_0
  SHA512 ccb4baa6674cd830cddb779216ce702b3cdba6de8a3d627c218861507c36bddd2861b0d0e8cad35001a1e9f0c3d5020404684c87dd05d85264ac166fa7f70589
  HEAD_REF master
  PATCHES patch.patch
)

file(COPY ${CMAKE_SOURCE_PATH}/cryptopp-config.cmake DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_SOURCE_PATH}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

if("pem-pack" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH PEM_PACK_SOURCE_PATH
        REPO noloader/cryptopp-pem
        REF 095f08ff2ef9bca7b81036a59f2395e4f08ce2e8
        SHA512 49912758a635faca1f49665ac9552b20576b46e0283aaabc19bb012bdc80586106452018e5088b9b46967717982ca6022ca968edc4cac96a7506d2b1a3e4bf13
        HEAD_REF master
    )

    file(GLOB PEM_PACK_FILES
        ${PEM_PACK_SOURCE_PATH}/*.h
        ${PEM_PACK_SOURCE_PATH}/*.cpp
    )
    file(COPY ${PEM_PACK_FILES} DESTINATION ${SOURCE_PATH})
endif()

# disable assembly on ARM Windows to fix broken build
if (VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE MATCHES "^arm")
    set(CRYPTOPP_DISABLE_ASM "ON")
else()
    set(CRYPTOPP_DISABLE_ASM "OFF")
endif()

# Dynamic linking should be avoided for Crypto++ to reduce the attack surface,
# so generate a static lib for both dynamic and static vcpkg targets.
# See also:
#   https://www.cryptopp.com/wiki/Visual_Studio#Dynamic_Runtime_Linking
#   https://www.cryptopp.com/wiki/Visual_Studio#The_DLL

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_SHARED=OFF
        -DBUILD_STATIC=ON
        -DBUILD_TESTING=OFF
        -DBUILD_DOCUMENTATION=OFF
        -DDISABLE_ASM=${CRYPTOPP_DISABLE_ASM}
)

vcpkg_cmake_install ()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cryptopp)

# There is no way to suppress installation of the headers and resource files in debug build.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/cryptopp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cryptopp/License.txt ${CURRENT_PACKAGES_DIR}/share/cryptopp/copyright)
