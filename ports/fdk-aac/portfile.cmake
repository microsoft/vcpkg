include(vcpkg_common_functions)
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO mstorsjo/fdk-aac
  REF a50eecf65b5ce5d4f03768c5c2cb4b492d2badad
  SHA512 1cb42e99d9d3112a42497f85c8ddbfb919a1c33bc8094408a828468762fe6d07c97940effa69d043c2d9923f3fa1805fd8c723154631609a6b0883eb4d3c6b27
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
