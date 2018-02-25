include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO lvandeve/lodepng
  REF 116f5b2ed7c4a9c6779ae291b79770727cbb11ad
  SHA512 746528e4cb4c8678a91f607ff7c2d61f651a19ef1efcd4694deb0d2191970674de7e13331004f7702b31a335474cf71364c8da0fdc7c75852db3cb896f00a375
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
