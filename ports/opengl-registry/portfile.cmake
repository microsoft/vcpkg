vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/OpenGL-Registry
  REF d38ff693f3e99ac5a61e3858de76c6c02976fa67
  SHA512 25cbbf92ec40a4b82eb73e117056338ffccf0f69dc05429cad83a6583e057ec8a43ba1e39ac9c4761d0258554581acecc003dade6faa41f9c4f67b39543575e3
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
