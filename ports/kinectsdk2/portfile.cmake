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

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    message(FATAL_ERROR "This port does not currently support architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

get_filename_component(KINECTSDK20_DIR "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Kinect\\v2.0;SDKInstallPath]" ABSOLUTE CACHE)
if(NOT EXISTS "${KINECTSDK20_DIR}")
    message(FATAL_ERROR "Error: Could not find Kinect for Windows SDK v2.x. It can be downloaded from https://www.microsoft.com/en-us/download/details.aspx?id=44561.")
endif()

file(
    INSTALL
        "${KINECTSDK20_DIR}/inc/Kinect.h"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/include
)

file(
    INSTALL
        "${KINECTSDK20_DIR}/Lib/${VCPKG_TARGET_ARCHITECTURE}/Kinect20.lib"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/lib
)

file(
    INSTALL
        "${KINECTSDK20_DIR}/Lib/${VCPKG_TARGET_ARCHITECTURE}/Kinect20.lib"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/debug/lib
)

# Handle copyright
file(COPY "${KINECTSDK20_DIR}/SDKEula.rtf" DESTINATION ${CURRENT_PACKAGES_DIR}/share/kinectsdk2)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/kinectsdk2/SDKEula.rtf ${CURRENT_PACKAGES_DIR}/share/kinectsdk2/copyright)
