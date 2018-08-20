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

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO baylej/tmx
    REF tmx_1.0.0
    HEAD_REF master
    SHA512 d045c45efd03f91a81dae471cb9ddc80d222b3ac52e13b729deeaf3e07d0a03b8e0956b30336ef410c72ddbbf33bea6811da5454b88d44b1db75683ef2a9383a
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" TMX_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_SHARED_LIBS=${TMX_SHARED}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/tmx/tmxExports.cmake ${CURRENT_PACKAGES_DIR}/lib/cmake/tmx/tmxTargets.cmake)
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/tmx")
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tmx/tmxTargets.cmake ${CURRENT_PACKAGES_DIR}/share/tmx/tmxExports.cmake)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/tmx RENAME copyright)
