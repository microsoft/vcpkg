vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/vslavik/winsparkle/releases/download/v0.8.1/WinSparkle-0.8.1.zip"
    FILENAME "winsparkle-081.zip"
    SHA512 05588793272618ca13fe884620f1ed421276b011a906f15c92f4879b1787c71b175ae1a170b80fe2adfdb7669eac90c38fac929a9bcf382388983f9aea25ba9c
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
else()
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
