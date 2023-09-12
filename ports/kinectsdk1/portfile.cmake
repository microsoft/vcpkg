set(KINECTSDK10_VERSION "v1.8")

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(ARCHITECTURE x86)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(ARCHITECTURE amd64)
else()
    message(FATAL_ERROR "This port does not currently support architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

vcpkg_download_distfile(KINECTSDK10_INSTALLER
    URLS "https://download.microsoft.com/download/E/1/D/E1DEC243-0389-4A23-87BF-F47DE869FC1A/KinectSDK-${KINECTSDK10_VERSION}-Setup.exe"
    FILENAME "KinectSDK-${KINECTSDK10_VERSION}-Setup.exe"
    SHA512 d7e886d639b4310addc7c1350311f81289ffbcd653237882da7bf3d4074281ed35d217cb8be101579cac880c574dd89c62cd6a87772d60905c446d0be5fd1932
)

vcpkg_find_acquire_program(DARK)

set(KINECTSDK10_WIX_INSTALLER "${KINECTSDK10_INSTALLER}")
set(KINECTSDK10_WIX_EXTRACT_DIR "${CURRENT_BUILDTREES_DIR}/src/installer/wix")
vcpkg_execute_required_process(
    COMMAND "${DARK}" -x "${KINECTSDK10_WIX_EXTRACT_DIR}" "${KINECTSDK10_WIX_INSTALLER}"
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
    LOGNAME extract-wix-${TARGET_TRIPLET}
)

file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/src/KinectSDK-${KINECTSDK10_VERSION}-${VCPKG_TARGET_ARCHITECTURE}")
set(KINECTSDK10_MSI_INSTALLER "installer\\wix\\AttachedContainer\\KinectSDK-${KINECTSDK10_VERSION}-${VCPKG_TARGET_ARCHITECTURE}.msi")
vcpkg_execute_required_process(
    COMMAND
        "${LESSMSI}"
        x
        "${KINECTSDK10_MSI_INSTALLER}"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/src"
    LOGNAME extract-msi-${TARGET_TRIPLET}
)
set(KINECTSDK10_DIR "${CURRENT_BUILDTREES_DIR}/src/KinectSDK-${KINECTSDK10_VERSION}-${VCPKG_TARGET_ARCHITECTURE}/SourceDir/Microsoft SDKs/Kinect/${KINECTSDK10_VERSION}")

file(
    INSTALL
        "${KINECTSDK10_DIR}/inc/NuiApi.h"
        "${KINECTSDK10_DIR}/inc/NuiImageCamera.h"
        "${KINECTSDK10_DIR}/inc/NuiSensor.h"
        "${KINECTSDK10_DIR}/inc/NuiSkeleton.h"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/include"
)

file(
    INSTALL
        "${KINECTSDK10_DIR}/lib/${ARCHITECTURE}/Kinect10.lib"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/lib"
)

file(
    INSTALL
        "${KINECTSDK10_DIR}/lib/${ARCHITECTURE}/Kinect10.lib"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/debug/lib"
)

configure_file("${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake" @ONLY)

# Handle copyright
file(INSTALL "${KINECTSDK10_DIR}/SDKEula.rtf" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
