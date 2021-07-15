string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" RBDL_STATIC)	

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO ORB-HD/rbdl-orb
  REF 8716ac5b344422a440d939d081c401242adb7f66
  SHA512 bbe99109a0642ecc87301b17fae90545deff79512bc8f334b2de4d17d77e84d8b42edc840c4dbdd6d739d1060b03c80e311d20c82c393b78c0ee404bb7fc5179
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
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DRBDL_BUILD_STATIC=${RBDL_STATIC}
        -DRBDL_BUILD_ADDON_LUAMODEL=ON
        -DRBDL_BUILD_ADDON_GEOMETRY=ON
        -DRBDL_BUILD_ADDON_URDFREADER=ON
        -DRBDL_BUILD_EXECUTABLES=OFF
)

vcpkg_cmake_install()

# # Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# # Remove duplicated include directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
