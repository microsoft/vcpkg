if (EXISTS "${CURRENT_INSTALLED_DIR}/share/rbdl/copyright")
    message(FATAL_ERROR "${PORT} conflict with rbdl, please remove rbdl before install ${PORT}.")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" RBDL_STATIC)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO ORB-HD/rbdl-orb
  REF 1157de022bcdd9e07a42ccd7ff793f138b5c746f
  SHA512 dc670eaa10b82038a30b61e183e51736ff08961c96861e6389a41386e56a8fbe39fac91df34e59602be2c768fe9c6bba9a4ee86c7e092a6bfeea0c79b27c8b29
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
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/RBDL PACKAGE_NAME RBDL)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
