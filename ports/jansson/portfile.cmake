include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO akheron/jansson
  REF v2.11
  SHA512 5dd94951e1aedd3f3a9ab6a43170d2395ec70c5a00e6da58538816b2dcd98835fc4ca43ab1e9b78864c01e48075505573f4f8d1da5c9d2c094622518d19525e8
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
