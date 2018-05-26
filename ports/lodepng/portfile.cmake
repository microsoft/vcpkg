include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO lvandeve/lodepng
  REF d03d7df9888aafb9c7f615895c34b05acf033908
  SHA512 a7139f839ad161075909611527645c75758959626fbb5d892dc1bfba8df2d4c3cfa86328de5534386e6053843727d2bc453fd439a2e329fd3be5d36d77903a0f
  HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
    -DDISABLE_INSTALL_HEADERS=ON
    -DDISABLE_INSTALL_TOOLS=ON
    -DDDISABLE_INSTALL_EXAMPLES=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/lodepng)


file(INSTALL ${SOURCE_PATH}/lodepng.h DESTINATION ${CURRENT_PACKAGES_DIR}/share/lodepng RENAME copyright)
