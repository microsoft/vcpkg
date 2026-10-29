set(REF e8f7cd0e35ac8d6f5667a021ff83d04b1fec41ef)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenGL-Registry
    REF "${REF}"
    SHA512 7b2eab04e54aa77294887f897f3091c07ecad38acc1dfb1e9d1efc3954d347a0b8c2666f3ceaf074dd17a3d97305f3d99494fe80c4b2f17d052183dfab1927c5
    HEAD_REF main
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
set(pc_file [=[
prefix=${pcfiledir}/../..
datadir=${prefix}/share
specdir=${datadir}/opengl
Name: khronos-opengl-registry
Description: Khronos OpenGL registry
Version: git@REF@
]=])
string(CONFIGURE "${pc_file}" pc_file @ONLY)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/pkgconfig/khronos-opengl-registry.pc" "${pc_file}")
