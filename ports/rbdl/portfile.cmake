string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" RBDL_STATIC)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO rbdl/rbdl
  REF "v${VERSION}"
  SHA512 85128dd7184a876d541278ebe0f986774c7c891b4925f320e14932f6809f8bbd07ef4b5d915afe9b49c2245bd494012993ae6643631f4157e3d217e9eccb6e48
  HEAD_REF master
  PATCHES
      0001-fix-eigen3.patch
)

if(NOT EXISTS "${SOURCE_PATH}/addons/urdfreader/thirdparty/urdfparser/CMakeLists.txt")
    vcpkg_from_github(
        OUT_SOURCE_PATH PARSER_SOURCE_PATH
        REPO ORB-HD/URDF_Parser
        REF 8fcc3174743cf3e7561ffb6625524f8133161df4
        SHA512 6cba22e98f23e74fd7c1dcb356d88b5e24c61913dc900e584ed313b1fcce5d6832ceafcf15a3ea7a56714ab82d3cd7d9f4350d3d242614561c836bd4735e3f4f
    )
    file(REMOVE_RECURSE "${SOURCE_PATH}/addons/urdfreader/thirdparty/urdfparser")
    file(RENAME "${PARSER_SOURCE_PATH}" "${SOURCE_PATH}/addons/urdfreader/thirdparty/urdfparser")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRBDL_BUILD_STATIC=${RBDL_STATIC}
        -DRBDL_BUILD_ADDON_LUAMODEL=ON
        -DRBDL_BUILD_ADDON_GEOMETRY=ON
        -DRBDL_BUILD_ADDON_URDFREADER=ON
        -DRBDL_BUILD_EXECUTABLES=OFF
        -DRBDL_VCPKG_BUILD=ON
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/RBDL PACKAGE_NAME RBDL)
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
