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
        ${CURRENT_PACKAGES_DIR}/include
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(ARCHITECTURE x86)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(ARCHITECTURE amd64)
else()
    message(FATAL_ERROR "This port does not currently support architecture: ${VCPKG_TARGET_ARCHITECTURE}")
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