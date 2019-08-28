include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/OpenGL-Registry
  REF e18e52a14e902a9ee29c5bf87478ac2ca21bb06b
  SHA512 3b883115e138178984a751ee314b0589a7a20db3bc7cff96fa0b886be1779c24031ce65847386aa2d4f42823b1597edccc5a9afc0aef42fea8611a44d2ca5df6
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
