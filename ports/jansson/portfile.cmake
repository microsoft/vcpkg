vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO akheron/jansson
  REF 684e18c927e89615c2d501737e90018f4930d6c5 # v2.14
  SHA512 e2cac3567bc860d10d9aa386ce370876cb21ff083a970abeb48112b6586b91cd101694a98cb05a06795fb04498e6bc2df3615fedb86635f5a998b68e5670e5b3
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
