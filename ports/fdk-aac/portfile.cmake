include(vcpkg_common_functions)
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO mstorsjo/fdk-aac
  REF 2326faaf8f2cdf2c3a9108ccdaf1d7551aec543e
  SHA512 8fd5413ff4020576c5f6a82d59c7fe413fe5eb40452827f4bcbeb351a5477839b37577c5330def78046798c20f3b445edab2a3ded85010aad974f2d5d0c8fef6
  HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/fdk-aac.def DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON -DDISABLE_INSTALL_TOOLS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/fdk-aac)
file(INSTALL ${SOURCE_PATH}/NOTICE DESTINATION ${CURRENT_PACKAGES_DIR}/share/fdk-aac RENAME copyright)
