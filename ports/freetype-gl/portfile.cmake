# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/freetype-gl)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rougier/freetype-gl
    REF 82fb152a74f01b1483ac80d15935fbdfaf3ed836
    SHA512 4842d9e66fd25dbb3a4e3f4bf597a0c1fc3c3c30e0cb1baae1c3306ddcb663ff9108d8fc01bde539fea7cb03a6329054f66166d9e448086358ab7b05953f5884
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/0001-Use-external-Glew-and-Freetype.patch"
)

# make sure that no "internal" libraries are used by removing them
file(REMOVE_RECURSE ${SOURCE_PATH}/windows/freetype)
file(REMOVE_RECURSE ${SOURCE_PATH}/windows/AntTweakBar)
file(REMOVE_RECURSE ${SOURCE_PATH}/windows/glew)
file(REMOVE ${SOURCE_PATH}/cmake/Modules/FindGLEW.cmake)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    #PREFER_NINJA
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
    OPTIONS
        -Dfreetype-gl_BUILD_APIDOC=OFF
        -Dfreetype-gl_BUILD_DEMOS=OFF
        -Dfreetype-gl_BUILD_TESTS=OFF
)

# We may soon install using a modified cmake process with install target
#vcpkg_install_cmake()
vcpkg_build_cmake(LOGFILE_ROOT install)

file(GLOB HEADER_FILES "${SOURCE_PATH}/*.h")
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/freetype-gl)

# DLL & LIB
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/freetype-gl.lib  DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Debug/freetype-gl.lib  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
#file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/makefont.exe  DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
#file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Debug/makefont.exe  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/freetype-gl RENAME copyright)
