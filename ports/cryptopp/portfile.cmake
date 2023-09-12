vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH CMAKE_SOURCE_PATH
  REPO abdes/cryptopp-cmake
  REF f857b775bcb4ff24e4993d85cce811587f8b0616 #CRYPTOPP_8_8_0
  SHA512 a33ef3393d051776672ecc15987dd55d848cb501f0d8cc19b411df49b47c1762469a0cb96a26132b154fa9c6ce36126f041f940e8c2f3651884b0d041dea580e
  HEAD_REF master
  PATCHES fix-git-branch.patch
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO weidai11/cryptopp
  REF 4d0cad5401d1a2c998b314bc89288c9620d3021d #CRYPTOPP_8_8_0
  SHA512 2e7885c0ee2666113ca1129f4b420be50b5edc9de0d817da0ee959c6d7595cda6b173dbb8e830c57078f9ccb449c357a75b029645886e8e3b7bcd338ac3d8b17
  HEAD_REF master
  PATCHES patch.patch
)

file(COPY "${CMAKE_SOURCE_PATH}/cryptopp" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_SOURCE_PATH}/cmake" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_SOURCE_PATH}/test" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_SOURCE_PATH}/cryptopp/cryptoppConfig.cmake" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_SOURCE_PATH}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

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
    file(INSTALL ${PEM_PACK_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
endif()

# disable assembly on ARM Windows to fix broken build
if (VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE MATCHES "^arm")
    set(CRYPTOPP_DISABLE_ASM "ON")
elseif(NOT DEFINED CRYPTOPP_DISABLE_ASM) # Allow disabling using a triplet file
    set(CRYPTOPP_DISABLE_ASM "OFF")
endif()

# Dynamic linking should be avoided for Crypto++ to reduce the attack surface,
# so generate a static lib for both dynamic and static vcpkg targets.
# See also:
#   https://www.cryptopp.com/wiki/Visual_Studio#Dynamic_Runtime_Linking
#   https://www.cryptopp.com/wiki/Visual_Studio#The_DLL

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCRYPTOPP_SOURCES=${SOURCE_PATH}
        -DCRTPTOPP_GIT_BRANCH=${VERSION}
        -DCRYPTOPP_BUILD_SHARED=OFF
        -DBUILD_STATIC=ON
        -DCRYPTOPP_BUILD_TESTING=OFF
        -DCRYPTOPP_BUILD_DOCUMENTATION=OFF
        -DDISABLE_ASM=${CRYPTOPP_DISABLE_ASM}
        -DUSE_INTERMEDIATE_OBJECTS_TARGET=OFF # Not required when we build static only
        -DCMAKE_POLICY_DEFAULT_CMP0063=NEW # Honor "<LANG>_VISIBILITY_PRESET" properties
    MAYBE_UNUSED_VARIABLES
        BUILD_STATIC
        USE_INTERMEDIATE_OBJECTS_TARGET
        CMAKE_POLICY_DEFAULT_CMP0063
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/cryptopp)

if(NOT VCPKG_BUILD_TYPE)
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
endif()
file(RENAME "${CURRENT_PACKAGES_DIR}/share/pkgconfig" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
vcpkg_fixup_pkgconfig()

# There is no way to suppress installation of the headers and resource files in debug build.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")


if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
file(COPY "${SOURCE_PATH}/License.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/License.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
