vcpkg_buildpath_length_warning(37)

set(KINECTSDK20_VERSION "v2.0_1409")
vcpkg_download_distfile(KINECTSDK20_INSTALLER
    URLS "https://download.microsoft.com/download/F/2/D/F2D1012E-3BC6-49C5-B8B3-5ACFF58AF7B8/KinectSDK-${KINECTSDK20_VERSION}-Setup.exe"
    FILENAME "KinectSDK-${KINECTSDK20_VERSION}-Setup.exe"
    SHA512 ae3b00f45282ab2ed6ea36c09e42e1b274074f41546ecfbe00facf1fffa2e5a762ffeffb9ba2194f716e8122e0fbd9a8ef63c62be68d2b50a40e4f8c5a821f5f
)

vcpkg_find_acquire_program(DARK)

set(KINECTSDK20_WIX_INSTALLER "${KINECTSDK20_INSTALLER}")
set(KINECTSDK20_WIX_EXTRACT_DIR "${CURRENT_BUILDTREES_DIR}/src/installer/wix")
vcpkg_execute_required_process(
    COMMAND ${DARK} -x ${KINECTSDK20_WIX_EXTRACT_DIR} ${KINECTSDK20_WIX_INSTALLER}
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
    LOGNAME extract-wix-${TARGET_TRIPLET}
)

file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/src/KinectSDK-${KINECTSDK20_VERSION}-x64")
set(KINECTSDK20_MSI_INSTALLER "installer\\wix\\AttachedContainer\\KinectSDK-${KINECTSDK20_VERSION}-x64.msi")
vcpkg_execute_required_process(
    COMMAND
        "${LESSMSI}"
        x
        "${KINECTSDK20_MSI_INSTALLER}"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/src"
    LOGNAME extract-msi-${TARGET_TRIPLET}
)
set(KINECTSDK20_DIR "${CURRENT_BUILDTREES_DIR}/src/KinectSDK-${KINECTSDK20_VERSION}-x64/SourceDir/Microsoft SDKs/Kinect/${KINECTSDK20_VERSION}")

file(
    INSTALL
        "${KINECTSDK20_DIR}/inc/"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/include"
)

file(
    INSTALL
        "${KINECTSDK20_DIR}/Lib/${VCPKG_TARGET_ARCHITECTURE}/Kinect20.lib"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/lib"
)

file(
    INSTALL
        "${KINECTSDK20_DIR}/Lib/${VCPKG_TARGET_ARCHITECTURE}/Kinect20.lib"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/debug/lib"
)

configure_file("${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake" @ONLY)

# Handle copyright
file(INSTALL "${KINECTSDK20_DIR}/SDKEula.rtf" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
