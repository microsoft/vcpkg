vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO luckyweNda/rcon
    REF 6ea49bbd54bbf7604e4e3f6fc2dbd4e507d7bd90
    SHA512 84fefc80e6c47decd9fedb2df1ce1c2671cf8159eb8d60d9b90e3208dd2bd5786eb1bbd526d1d252cd1fc4c6bbb0377712b224c8a4b7ea66b52c6184c241f85e
    HEAD_REF main
)

# Install include directory
file(INSTALL "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Copy usage file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
