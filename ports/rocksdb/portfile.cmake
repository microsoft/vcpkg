include(vcpkg_common_functions)

find_program(GIT git)

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  message(FATAL_ERROR "Rocksdb only supports x64")
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO facebook/rocksdb
  REF 18c63af6ef2b9f014c404b88488ae52e6fead03c
  SHA512 8dd4d27768feba6d9ddb61debe6cae21fa6d25c27dc347cba3b28cc39d2c1fa860dba7c8adedba4b40883eccccca190b60941cf958855c6b70ec5a3b96c20ac5
  HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
    "${CMAKE_CURRENT_LIST_DIR}/fix-building-both-static-and-shared.patch"
    "${CMAKE_CURRENT_LIST_DIR}/fix-third-party-deps.patch"
)


if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  set(BUILD_STATIC_LIBRARY ON)
else()
  set(BUILD_STATIC_LIBRARY OFF)
endif()

if(VCPKG_CRT_LINKAGE STREQUAL static)
  set(WITH_MD_LIBRARY OFF)
else()
  set(WITH_MD_LIBRARY ON)
endif()

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
  -DGIT_EXECUTABLE=${GIT}
  -DGFLAGS=1
  -DSNAPPY=1
  -DLZ4=1
  -DZLIB=1
  -DCURRENT_INSTALLED_DIR=${CURRENT_INSTALLED_DIR}
  -DBUILD_STATIC_LIBRARY=${BUILD_STATIC_LIBRARY}
  -DFAIL_ON_WARNINGS=OFF
  -DWITH_MD_LIBRARY=${WITH_MD_LIBRARY}
  OPTIONS_DEBUG
  -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake(DISABLE_PARALLEL)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/rocksdb RENAME copyright)

vcpkg_copy_pdbs()
