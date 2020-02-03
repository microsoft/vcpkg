vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/OpenGL-Registry
  REF 2223f5bebde4aa6b170fb32cdaaf580703fddb67
  SHA512 4e9b570f242942bd45a6601a6b0fcf1dc265c6ba03acaf782a639e7399842dd7350c2d4876236df80a070b2bd9ce7cee88cf2d85f2c50cfba7878d1f9379bbe9
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
