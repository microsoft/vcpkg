if (EXISTS "${CURRENT_INSTALLED_DIR}/share/rbdl/copyright")
    message(FATAL_ERROR "${PORT} conflict with rbdl, please remove rbdl before install ${PORT}.")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" RBDL_STATIC)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO ORB-HD/rbdl-orb
  REF b22abab856a90dbc62e6b2e79f148bd383b5ce43
  SHA512 744a60145243454a9d148971d998ae7a3cc5b9d66131b5d6f3c7be80d6c9ef8b8bf4390b9d1b90b14be6c619c2e1d14c7c6104b3ca6e606e22e3581b548e4f9d	
  HEAD_REF master
)

vcpkg_from_github(
  OUT_SOURCE_PATH PARSER_SOURCE_PATH
  REPO ORB-HD/URDF_Parser
  REF  0f3310d766c658b72d54560833012c8fe63ce9d7
  SHA512 6cd8e300cc47b5a5370efb5a4cd843a1621e2832b790daedc1e260ba5bbcaaabdbcddce239f93c3900258093d483d332110ba7e9f0b4b6cda64ce51b6cf2365d
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

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
