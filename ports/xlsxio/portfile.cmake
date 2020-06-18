vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brechtsanders/xlsxio
    REF 7224eecf08b4b0584ec7601d3cc34c56dc83eb96
    SHA512 41350f26abee738e1748f0d02e947fe5b0907104b39d5c42ec5b76c14f042c3139a5f74b59d3a7cde374f5bab2c9644d33a94d65c1e6c6b18b7b0e3ef89b8e99
    HEAD_REF master
    PATCHES
        fix-build-error.patch
        fix-compile-definitions.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(BUILD_STATIC OFF)
  set(BUILD_SHARED ON)
else()
  set(BUILD_STATIC ON)
  set(BUILD_SHARED OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TOOLS=OFF
        -DBUILD_STATIC=${BUILD_STATIC}
        -DBUILD_SHARED=${BUILD_SHARED}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
