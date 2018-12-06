include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/glslang
  REF b5b5f918c6b72d7cf2ee73641cc6c6ddb211ca70
  SHA512 ec0f7a23fa60457a481c7b3acf4c127c3bf898d23655d346aeafb304f74e798d632c83d676873f2c764d241de6dc4392cff8d6ce0ee509a4b74ee2233b01c008
  HEAD_REF master
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(RENAME "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/tools")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")

# Handle copyright
file(COPY ${CMAKE_CURRENT_LIST_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/glslang)
