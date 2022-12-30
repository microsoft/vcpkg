vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KhronosGroup/OpenGL-Registry
  REF 5bae8738b23d06968e7c3a41308568120943ae77
  SHA512 3f8c58474627ded85d95f8a4d86329ec4f55b179eb2df393983462d42088e9496eef1a5980481f4b085e6ffb749cd5dd3b312a1e2b7b8189d9723a673ec65b0d
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

# pc layout from cygwin (consumed in xserver!)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/pkgconfig/khronos-opengl-registry.pc" [=[
prefix=${pcfiledir}/../..
datadir=${prefix}/share
specdir=${datadir}/opengl
Name: khronos-opengl-registry
Description: Khronos OpenGL registry
Version: git4594c03239fb76580bc5d5a13acb2a8f563f0158
]=])

# grep -R -B1 "SPDX-License-Identifier: " packages/opengl-registry_<TRIPLET>
vcpkg_spdx_license_file(MIT)
vcpkg_spdx_license_file(Apache-2.0)
vcpkg_install_copyright(FILE_LIST "${MIT}" "${Apache-2.0}" COMMENT [[
Most headers are
Copyright 2013-2020 The Khronos Group Inc.
SPDX-License-Identifier: MIT

Some headers are
Copyright 2008-2020 The Khronos Group Inc.
SPDX-License-Identifier: Apache-2.0
]])
