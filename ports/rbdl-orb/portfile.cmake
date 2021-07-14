string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" RBDL_STATIC)	

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO ORB-HD/rbdl-orb
  REF 5421f76e19b428f8698bb021159599528962cc0b
  SHA512 c0b5c1e552403a3a21baacb12913248066e0d0b10c78972b5a559cdfa87036805fc46327aeb8dc17786f28ec3a08a1c0a3b28e3a623933afdc2974eb5007984a
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
