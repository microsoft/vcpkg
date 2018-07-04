include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO lvandeve/lodepng
  REF bd8f274fb51ef18b6d26b5f106ae4bef2150622e
  SHA512 6082491dc5d6194e3ed2522c74de73f48f43ae91a5e47e04309ef7267a92412f860fec02241b5c0bd7728b931f4fbe6983727d9cf701a2cd4bd4affc6962d9b3
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
