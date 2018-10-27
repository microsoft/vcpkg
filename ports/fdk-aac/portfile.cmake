include(vcpkg_common_functions)
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO mstorsjo/fdk-aac
  REF e45ae429b9ca8f234eb861338a75b2d89cde206a
  SHA512 e4d0ec632a67642312bd0c812849601452d4ba45b31bc2f2a9392bba5fe2320b2099c5c7077c9571ea270804979039182060dc1acacdc397ca2a9b8ca43301a3
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
