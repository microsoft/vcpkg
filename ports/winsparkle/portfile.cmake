vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/vslavik/winsparkle/releases/download/v${VERSION}/WinSparkle-${VERSION}.zip"
    FILENAME "winsparkle-v${VERSION}.zip"
    SHA512 73ea15e81a6bffd5268674f633f0aa55660764c8b8f35b7fac073e5f82c85b4e888172b3dfd9c3e71341bd23e5314539dd0f47360f89473f94b39f2352910012
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

file(GLOB HEADER_LIST "${SOURCE_PATH}/include/*.h")
file(INSTALL ${HEADER_LIST} DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(GLOB TOOLS_LIST "${SOURCE_PATH}/bin/*.bat")
file(INSTALL ${TOOLS_LIST} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

# Note: It is an explicit design goal for WinSparkle to be a single
# self-contained DLL with no external dependencies (to the point that
# it even links to static CRT!). This matters for e.g. in-app delta updates
# or re-launching the app after update. It is not statically linked even if a
# static linking is used for everything else.
set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    file(INSTALL "${SOURCE_PATH}/Release/WinSparkle.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(INSTALL "${SOURCE_PATH}/Release/WinSparkle.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(INSTALL "${SOURCE_PATH}/Release/WinSparkle.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

    # We have no debug, but since Winsparkle is a self-contained dll, we can copy it to the Debug folder as well
    file(INSTALL "${SOURCE_PATH}/Release/WinSparkle.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(INSTALL "${SOURCE_PATH}/Release/WinSparkle.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(INSTALL "${SOURCE_PATH}/Release/WinSparkle.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    file(INSTALL "${SOURCE_PATH}/x64/Release/WinSparkle.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(INSTALL "${SOURCE_PATH}/x64/Release/WinSparkle.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(INSTALL "${SOURCE_PATH}/x64/Release/WinSparkle.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

    # We have no debug, but since Winsparkle is a self-contained dll, we can copy it to the Debug folder as well
    file(INSTALL "${SOURCE_PATH}/x64/Release/WinSparkle.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(INSTALL "${SOURCE_PATH}/x64/Release/WinSparkle.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(INSTALL "${SOURCE_PATH}/x64/Release/WinSparkle.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    file(INSTALL "${SOURCE_PATH}/ARM64/Release/WinSparkle.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(INSTALL "${SOURCE_PATH}/ARM64/Release/WinSparkle.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(INSTALL "${SOURCE_PATH}/ARM64/Release/WinSparkle.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

    # We have no debug, but since Winsparkle is a self-contained dll, we can copy it to the Debug folder as well
    file(INSTALL "${SOURCE_PATH}/ARM64/Release/WinSparkle.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(INSTALL "${SOURCE_PATH}/ARM64/Release/WinSparkle.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(INSTALL "${SOURCE_PATH}/ARM64/Release/WinSparkle.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
else()
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
