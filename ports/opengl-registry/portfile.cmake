include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/OpenGL-Registry
  REF 4594c03239fb76580bc5d5a13acb2a8f563f0158
  SHA512 c005a4eb7e5c17002647e7762ae1a7ecba0d0780a62d66f1afd3b7f45c1ca49bd5a069ab0fabb94de3ec971604586457932941fa8eb924cf5ac3a959d8f5f146
  HEAD_REF master
)

file(COPY ${SOURCE_PATH}/api/GL DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/api/GLES DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/api/GLES2 DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/api/GLES3 DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/api/GLSC DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/api/GLSC2 DESTINATION ${CURRENT_PACKAGES_DIR}/include)

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
