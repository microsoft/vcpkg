string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" RBDL_STATIC)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO rbdl/rbdl
  REF 6e92742d469efaf59ec2503882693b621f41eca8
  SHA512 d266732fe50a4cd5c55f9ff838649157e48994744f39d9eda9feee640dd400a5bb35ca620386ca65c9f1cdcb1adc923c34809dcb025bd6fc052baa9df57a4a6f
  HEAD_REF master
)

vcpkg_from_github(
  OUT_SOURCE_PATH PARSER_SOURCE_PATH
  REPO ORB-HD/URDF_Parser
  REF 8fcc3174743cf3e7561ffb6625524f8133161df4
  SHA512 6cba22e98f23e74fd7c1dcb356d88b5e24c61913dc900e584ed313b1fcce5d6832ceafcf15a3ea7a56714ab82d3cd7d9f4350d3d242614561c836bd4735e3f4f
)
if(NOT EXISTS "${SOURCE_PATH}/addons/urdfreader/thirdparty/urdfparser/CMakeLists.txt")
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

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
