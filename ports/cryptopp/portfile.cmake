include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH CMAKE_SOURCE_PATH
  REPO noloader/cryptopp-cmake
  REF 6d0666c457fbbf6f81819fd2b80f0cb5b6646593
  SHA512 0341f14ce734afaee8bcc1db1716684f241499c692a5478c83a3df3fd2e5331cd04b2f4f51d43cce231ca1d9fbe76220639573c05ef06be0cf33081a1ef7ab30
  HEAD_REF master
  PATCHES
    cmake.patch
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO weidai11/cryptopp
  REF CRYPTOPP_8_2_0
  SHA512 d2dcc107091d00800de243abdce8286ccd7fcc5707eebf88b97675456a021e62002e942b862db0465f72142951f631c0c1f0b2ba56028b96461780a17f2dfdf9
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

# disable assembly on OSX and ARM Windows to fix broken build
if (VCPKG_TARGET_IS_OSX)
    set(CRYPTOPP_DISABLE_ASM "ON")
elseif (VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE MATCHES "^arm")
    set(CRYPTOPP_DISABLE_ASM "ON")
else()
    set(CRYPTOPP_DISABLE_ASM "OFF")
endif()


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
        -DDISABLE_ASM=${CRYPTOPP_DISABLE_ASM}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/cryptopp)

# There is no way to suppress installation of the headers and resource files in debug build.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/cryptopp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cryptopp/License.txt ${CURRENT_PACKAGES_DIR}/share/cryptopp/copyright)
