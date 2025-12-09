vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
string(REPLACE "." "_" CRYPTOPP_VERSION "${VERSION}")

vcpkg_from_github(
  OUT_SOURCE_PATH CMAKE_SOURCE_PATH
  REPO abdes/cryptopp-cmake
  REF "866aceb8b13b6427a3c4541288ff412ad54f11ea"
  SHA512 "c891aa30f9bd26383617f3f224d5b098f9aca3342487a136af3dbe70ffae9a7b8590248717f16d665870c93992fed3b79c727c4deb6e8b060eec56ce1aa8cfca"
  HEAD_REF master
)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO weidai11/cryptopp
  REF "60f81a77e0c9a0e7ffc1ca1bc438ddfa2e43b78e"
  SHA512 "0645de8710057722ce6543a7dbf93b2ef798fbf7966955c84708ba0d960826911e8f6b1080807a96d77debe527c063b84979d521c6b1e5ce3f5177bd1126b989"
  HEAD_REF master
  PATCHES
      patch.patch
      cryptopp.patch
)

file(COPY "${CMAKE_SOURCE_PATH}/cryptopp" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_SOURCE_PATH}/cmake" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_SOURCE_PATH}/test" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_SOURCE_PATH}/cryptopp/cryptoppConfig.cmake" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_SOURCE_PATH}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        pem-pack CRYPTOPP_USE_PEM_PACK
)

if(CRYPTOPP_USE_PEM_PACK)
    vcpkg_from_github(
        OUT_SOURCE_PATH PEM_PACK_SOURCE_PATH
        REPO noloader/cryptopp-pem
        REF 64782e531d116ffbf83ca80614ac408dbb3fd775
        SHA512 154cf045f822a0da54a88ceb89d5b42cb8ad2eface73eb32a8eee0c4e60be10f4692442f1913f58e894b46412884907f5f70d99d1691ccf52e0aa50c9c9943cd
        HEAD_REF master
    )
    list(APPEND FEATURE_OPTIONS
        -Dcryptopp-pem_SOURCE_DIR="${PEM_PACK_SOURCE_PATH}"
    )
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
        -DCRYPTOPP_BUILD_SHARED=OFF
        -DBUILD_STATIC=ON
        -DCRYPTOPP_BUILD_TESTING=OFF
        -DCRYPTOPP_BUILD_DOCUMENTATION=OFF
        -DCRYPTOPP_DISABLE_ASM=${CRYPTOPP_DISABLE_ASM}
        -DUSE_INTERMEDIATE_OBJECTS_TARGET=OFF # Not required when we build static only
        -DCMAKE_POLICY_DEFAULT_CMP0063=NEW # Honor "<LANG>_VISIBILITY_PRESET" properties
        ${FEATURE_OPTIONS}
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
