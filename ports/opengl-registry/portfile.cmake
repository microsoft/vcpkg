vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/OpenGL-Registry
  REF 3530768138c5ba3dfbb2c43c830493f632f7ea33
  SHA512 1b2260e2baf2f40964ff6677ce2c5f0e970752408e94b251d443de57c2021d8848dda8ba61ba67547692dfd283fd2351fc900da60e3973f14b7b9be8a5ec5145
  HEAD_REF master
)

file(COPY "${SOURCE_PATH}/api/GL" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/api/GLES" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/api/GLES2" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/api/GLES3" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/api/GLSC" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/api/GLSC2" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(GLOB reg_files "${SOURCE_PATH}/xml/*.xml" "${SOURCE_PATH}/xml/readme.pdf" "${SOURCE_PATH}/xml/*.rnc" "${SOURCE_PATH}/xml/reg.py")
file(COPY
  ${reg_files}
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/opengl"
)

vcpkg_install_copyright(FILE_LIST "${CURRENT_PORT_DIR}/copyright")

# pc layout from cygwin (consumed in xserver!)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/pkgconfig/khronos-opengl-registry.pc" [=[
prefix=${pcfiledir}/../..
datadir=${prefix}/share
specdir=${datadir}/opengl
Name: khronos-opengl-registry
Description: Khronos OpenGL registry
Version: git3530768138c5ba3dfbb2c43c830493f632f7ea33
]=])
