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

get_filename_component(KINECTSDK10_DIR "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Kinect;SDKInstallPath]" ABSOLUTE CACHE)
if(NOT EXISTS "${KINECTSDK10_DIR}")
    message(FATAL_ERROR "Error: Could not find Kinect for Windows SDK v1.x.")
endif()

file(
    INSTALL
        "${KINECTSDK10_DIR}/inc/NuiApi.h"
        "${KINECTSDK10_DIR}/inc/NuiImageCamera.h"
        "${KINECTSDK10_DIR}/inc/NuiSensor.h"
        "${KINECTSDK10_DIR}/inc/NuiSkeleton.h"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/include/kinectsdk1
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(ARCHITECTURE x86)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(ARCHITECTURE amd64)
endif()

file(
    INSTALL
        "${KINECTSDK10_DIR}/lib/${ARCHITECTURE}/Kinect10.lib"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/lib
)

file(
    INSTALL
        "${KINECTSDK10_DIR}/lib/${ARCHITECTURE}/Kinect10.lib"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/debug/lib
)

# Handle copyright
file(COPY "${KINECTSDK10_DIR}/SDKEula.rtf" DESTINATION ${CURRENT_PACKAGES_DIR}/share/kinectsdk1)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/kinectsdk1/SDKEula.rtf ${CURRENT_PACKAGES_DIR}/share/kinectsdk1/copyright)