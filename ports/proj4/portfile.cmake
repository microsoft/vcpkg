include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OSGeo/PROJ
    REF 6.1.1
    SHA512 d7c13eec5bc75ace132b7a35118b0e254b9e766cad7bfe23f8d1ec52c32e388607b4f04e9befceef8185e25b98c678c492a6319d19a5e62d074a6d23474b68fa
    HEAD_REF master
    PATCHES fix-sqlite3-bin.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(VCPKG_BUILD_SHARED_LIBS ON)
else()
  set(VCPKG_BUILD_SHARED_LIBS OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
    -DBUILD_LIBPROJ_SHARED=${VCPKG_BUILD_SHARED_LIBS}
    -DPROJ_LIB_SUBDIR=lib
    -DPROJ_INCLUDE_SUBDIR=include
    -DPROJ_DATA_SUBDIR=share/proj4
    -DBUILD_CCT=OFF
    -DBUILD_CS2CS=OFF
    -DBUILD_GEOD=OFF
    -DBUILD_GIE=OFF
    -DBUILD_PROJ=OFF
    -DBUILD_PROJINFO=OFF
    -DPROJ_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/proj4)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/proj4 RENAME copyright)
