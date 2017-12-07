include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO akheron/jansson
  REF v2.10
  SHA512  0859c8a29c1cb7e406d3eb369285500e98ee23677e3a6af6cd81511c57a6aa8dbabe4a8c7b673a3000203b68f74d84786817aec76cb1e85af217268159bda4b6
  HEAD_REF master
)

if(VCPKG_CRT_LINKAGE STREQUAL static)
  set(JANSSON_STATIC_CRT  ON)
else()
  set(JANSSON_STATIC_CRT  OFF)
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
  OPTIONS
  -DJANSSON_STATIC_CRT=${JANSSON_STATIC_CRT}
  -DJANSSON_EXAMPLES=OFF
  -DJANSSON_WITHOUT_TESTS=ON
  -DJANSSON_BUILD_SHARED_LIBS=${JANSSON_BUILD_SHARED_LIBS}
  -DUSE_WINDOWS_CRYPTOAPI=${USE_WINDOWS_CRYPTOAPI}
)

vcpkg_install_cmake(DISABLE_PARALLEL)
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/jansson RENAME copyright)

vcpkg_copy_pdbs()
