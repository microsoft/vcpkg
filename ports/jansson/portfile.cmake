vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO akheron/jansson
  REF e9ebfa7e77a6bee77df44e096b100e7131044059 # v2.13.1
  SHA512 88a59c1cf5150699def17c86192ca9bacdfe6669319f770c3fbf14fa8edc48b4bb015a4a634a09db40fba9054320ac7c133c4d156f813af540a636f7825f0610
  HEAD_REF master
)

if(VCPKG_CRT_LINKAGE STREQUAL static)
  set(JANSSON_STATIC_CRT ON)
else()
  set(JANSSON_STATIC_CRT OFF)
endif()


if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(JANSSON_BUILD_SHARED_LIBS ON)
else()
  set(JANSSON_BUILD_SHARED_LIBS OFF)
endif()

# Jansson tries to random-seed its hash table with system-provided entropy.
# This is not ported to UWP yet.
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  set(USE_WINDOWS_CRYPTOAPI OFF)
else()
  set(USE_WINDOWS_CRYPTOAPI ON)
endif()

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DJANSSON_STATIC_CRT=${JANSSON_STATIC_CRT}
    -DJANSSON_EXAMPLES=OFF
    -DJANSSON_WITHOUT_TESTS=ON
    -DJANSSON_BUILD_SHARED_LIBS=${JANSSON_BUILD_SHARED_LIBS}
    -DUSE_WINDOWS_CRYPTOAPI=${USE_WINDOWS_CRYPTOAPI}
    -DJANSSON_INSTALL_CMAKE_DIR:STRING=share/jansson
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()
