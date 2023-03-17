vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO owent/libcopp
    REF "v${VERSION}"
    SHA512 0e18641a8d94527417b9c85b3e2ddd60c6c3dc10a9ccf75186cec4344239114245c50ac154a411f3e42a1f9e021a9bcf3c6b71b0cd2f9be82a76b0cd10791589
    HEAD_REF v2
    PATCHES fix-x86-windows.patch
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/BOOST_LICENSE_1_0.txt" "${SOURCE_PATH}/LICENSE")

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libcopp)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/libcopp/libcopp-config.cmake" "set(\${CMAKE_FIND_PACKAGE_NAME}_SOURCE_DIR \"${SOURCE_PATH}\")" "")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
