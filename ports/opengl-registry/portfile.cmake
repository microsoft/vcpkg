include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/OpenGL-Registry
  REF 3c9ab309994c2baeb5572aa0befd5f405166a275
  SHA512 f53018fe6dfb926dd6c1ce64ffde19b650a9071a1f6fa0c7a1596237e4ff84c3ff0092fb80811c4fea9b533c4b8607ed51f328d683d8f4aac18f0616f58b56a4
  HEAD_REF master
)

file(COPY ${SOURCE_PATH}/api/GL DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY
  ${SOURCE_PATH}/xml/gl.xml
  ${SOURCE_PATH}/xml/glx.xml
  ${SOURCE_PATH}/xml/wgl.xml
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/opengl-registry
)

# Using the Makefile because it is the smallest file with a complete copy of the license text
file(
  INSTALL ${SOURCE_PATH}/xml/Makefile
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/opengl-registry
  RENAME copyright
)
