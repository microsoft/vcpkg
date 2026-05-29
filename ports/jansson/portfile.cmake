vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO akheron/jansson
  REF v${VERSION}
  SHA512 99cecde543107c5a3f602fde0bb4ac9082dc6df307f6b1ca65c38921ada02861a19d43a5a8482379f125a20a933634f458046039b15e492ea63823341091ff9a
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
