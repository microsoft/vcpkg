include(vcpkg_common_functions)
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO mstorsjo/fdk-aac
  REF a30bfced6b6d6d976c728552d247cb30dd86e238
  SHA512 07371b78998b2330022ca5f4b6c605a30d279faef28b3fb53d03bbf7163c87bed9432fcd3efbee70906453e7599bc7191e6aeb0bc88b35dcfb79c2a935eb327d
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
