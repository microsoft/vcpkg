vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO akheron/jansson
  REF e9ebfa7e77a6bee77df44e096b100e7131044059 # v2.14
  SHA512 88a59c1cf5150699def17c86192ca9bacdfe6669319f770c3fbf14fa8edc48b4bb015a4a634a09db40fba9054320ac7c133c4d156f813af540a636f7825f0610
  HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" JANSSON_STATIC_CRT)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" JANSSON_BUILD_SHARED_LIBS)

# Jansson tries to random-seed its hash table with system-provided entropy.
# This is not ported to UWP yet.
if(VCPKG_TARGET_IS_UWP)
  set(USE_WINDOWS_CRYPTOAPI OFF)
else()
  set(USE_WINDOWS_CRYPTOAPI ON)
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DJANSSON_STATIC_CRT=${JANSSON_STATIC_CRT}
    -DJANSSON_EXAMPLES=OFF
    -DJANSSON_WITHOUT_TESTS=ON
    -DJANSSON_BUILD_DOCS=OFF
    -DJANSSON_BUILD_SHARED_LIBS=${JANSSON_BUILD_SHARED_LIBS}
    -DUSE_WINDOWS_CRYPTOAPI=${USE_WINDOWS_CRYPTOAPI}
    -DJANSSON_INSTALL_CMAKE_DIR:STRING=share/jansson
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
