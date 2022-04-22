vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO owent/libcopp
    REF 1.4.1
    SHA512 eba06bd2de7c9ee557cdd0bf79e0c53e37722b671347436322c14c99e94d955477bfc0980a4f59a5c31051e108f952ec96791024c45fa8eeaa5f7a49099dd8ae
    HEAD_REF v2
)

# atframework/cmake-toolset needed as a submodule for configure cmake
vcpkg_from_github(
  OUT_SOURCE_PATH ATFRAMEWORK_CMAKE_TOOLSET
  REPO atframework/cmake-toolset
  REF v1.3.5
  SHA512 5048c204eb6358547d99712a06866836e1a6dc20dee44cc33fae77181bdf9ece5686f30062eff6a231e1ec898d5a37ebaddb243e7e3484c002bb96240aa496a5
  HEAD_REF main
  )

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS "-DATFRAMEWORK_CMAKE_TOOLSET_DIR=${ATFRAMEWORK_CMAKE_TOOLSET}"
)

vcpkg_cmake_install()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/BOOST_LICENSE_1_0.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libcopp)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/libcopp/libcopp-config.cmake" "set(\${CMAKE_FIND_PACKAGE_NAME}_SOURCE_DIR \"${SOURCE_PATH}\")" "")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
