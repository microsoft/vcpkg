include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO lvandeve/lodepng
  REF 8a0f16afe74a6abf85e3b45e9558283022021a59
  SHA512 189dde0a0982822b6dfc3f886d8035338ed200958eed8394c5c64aa97ddcf758b3989beae14ce8f26a78efa9fb4b94932bb02b41cacd62bd62a46ebf9b324def
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
