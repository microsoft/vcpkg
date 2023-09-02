vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO juce-framework/JUCE
  REF "${VERSION}"
  SHA512 3182f54d5003c58a237f1aecf35b25ee76dd8c9d4026f14f218c79f8a8954e393ac821f009fcae1f535fe61c11fea4e6a263b4069d89a8ca9dbc644fd2139c4f
  HEAD_REF master
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DJUCE_BUILD_EXTRAS=ON
    -DJUCE_ENABLE_MODULE_SOURCE_GROUPS=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
  CONFIG_PATH "lib/cmake/${PORT}-${VERSION}"
)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_copy_tools(
  TOOL_NAMES juce_lv2_helper juce_vst3_helper juceaide 
  SEARCH_DIR "${CURRENT_PACKAGES_DIR}/bin/${PORT}-${VERSION}"
  AUTO_CLEAN
)

file(GLOB JUCE_MODULES_FOLDERS "${CURRENT_PACKAGES_DIR}/include/${PORT}-${VERSION}/modules/*")
foreach(JUCE_MODULE_FOLDER IN LISTS JUCE_MODULES_FOLDERS)
  file(
    COPY "${JUCE_MODULE_FOLDER}"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
  )
endforeach()

# TODO: Fix cmake references to FS and tools.

file(REMOVE_RECURSE 
  "${CURRENT_PACKAGES_DIR}/bin" 
  "${CURRENT_PACKAGES_DIR}/debug" 
  "${CURRENT_PACKAGES_DIR}/include/${PORT}-${VERSION}"
  "${CURRENT_PACKAGES_DIR}/lib"
)

file(
  INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" 
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

vcpkg_install_copyright(
  FILE_LIST "${SOURCE_PATH}/LICENSE.md"
)
