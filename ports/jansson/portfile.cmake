include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO akheron/jansson
  REF f92e15deddb703ded3c74d7e86b00d261d1d16eb
  SHA512 3ada45cd9b2fc7c1b20d11ce508db72a9ab2565b12d1bf45a5017e43435002f3488d92db9e0278101a83052907c5d51eb844a8389717a8f31eb93d1e135159f7
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

vcpkg_fixup_cmake_targets(CONFIG_PATH share/jansson)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/jansson RENAME copyright)

vcpkg_copy_pdbs()
