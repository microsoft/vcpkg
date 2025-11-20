vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO Alan-Jowett/dagir
  REF 0.1.0
  SHA512 0450B03C282DAA9B941A56283CCC00663C8EB66C9D02BDAE05D2EA5DD60C4048A30BA4B4D3F51FE51D7A7F43132D48989140FC02D088522A2177FF779C204ED3
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH} OPTIONS -DDAGIR_BUILD_TESTS=OFF -DDAGIR_EXAMPLES=OFF)
vcpkg_cmake_install()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/include")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/share/dagir")
vcpkg_cmake_config_fixup()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/dagir")
if(EXISTS "${SOURCE_PATH}/LICENSE")
  vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
endif()

file(WRITE "${CURRENT_PACKAGES_DIR}/share/dagir/DagIRTargets.cmake" "add_library(dagir::dagir INTERFACE IMPORTED)\nset_target_properties(dagir::dagir PROPERTIES INTERFACE_INCLUDE_DIRECTORIES \"\${CMAKE_CURRENT_LIST_DIR}/../../include\")\n")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/dagir/DagIRConfig.cmake" "include(\"\${CMAKE_CURRENT_LIST_DIR}/DagIRTargets.cmake\")\n")
