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
    REPO pngwriter/pngwriter
    REF 0.7.0
    SHA512 3e4ef098e4d715d18844cada64f32dbf079fdd1f7a64b6fe5e19584094f6b2a61f80c53804f936b6eefd7ef9dad4a01a7210b1273939d385a0850e48f8ba6683
    HEAD_REF master
)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/PNGwriter)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/PNGwriter/PNGwriterConfig.cmake ${CURRENT_PACKAGES_DIR}/share/PNGwriter/PNGwriterConfig.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/PNGwriter/PNGwriterTargets-debug.cmake ${CURRENT_PACKAGES_DIR}/share/PNGwriter/PNGwriterTargets-debug.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/PNGwriter/PNGwriterTargets-release.cmake ${CURRENT_PACKAGES_DIR}/share/PNGwriter/PNGwriterTargets-release.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/PNGwriter/PNGwriterConfigVersion.cmake ${CURRENT_PACKAGES_DIR}/share/PNGwriter/PNGwriterConfigVersion.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/PNGwriter/PNGwriterTargets.cmake ${CURRENT_PACKAGES_DIR}/share/PNGwriter/PNGwriterTargets.cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/doc/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/pngwriter RENAME copyright)
