string(REPLACE "." "_" VERSION_NAME ${VERSION})
set(LIVEPP_FILE LPP_${VERSION_NAME}.zip)

vcpkg_download_distfile(
    ARCHIVE
    URLS https://liveplusplus.tech/downloads/${LIVEPP_FILE}
    FILENAME "${LIVEPP_FILE}"
    SHA512 f7407c1c5487bce086af0044e5d34913f3f10e75cef3485b65241b6f3092c187b8127e1879e93ab4e9b4d48f156b39e31f08cea3c47a31d455bff28be570120d
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

file(INSTALL "${SOURCE_PATH}/API" DESTINATION "${CURRENT_PACKAGES_DIR}/include/LivePP" PATTERN "*.txt" EXCLUDE)
file(INSTALL "${SOURCE_PATH}/Agent" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(INSTALL "${SOURCE_PATH}/Broker" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(INSTALL "${SOURCE_PATH}/CLI" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-${PORT}Config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/global_preferences.json" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/Broker")
if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/global_preferences_default.json")
    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/global_preferences_default.json" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/Broker")
endif()
if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/global_preferences_override.json")
    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/global_preferences_override.json" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/Broker")
endif()

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" [[As of 2025-06-14, this software is bound by the "END USER LICENSE AGREEMENT" PDF located at
https://liveplusplus.tech/downloads/LPP_EULA.pdf
]])
