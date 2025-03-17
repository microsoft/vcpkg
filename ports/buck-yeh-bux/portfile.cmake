vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO buck-yeh/bux
    REF "${VERSION}"
    SHA512 884c49a8a07cb2acf242bb3b7a8b6c7aeda9eebe7723887ce3a6c081aaf8f628d4f4a8dfe4adb7550977ab6e18730bc9c45ad4f326a5f4a8fc45448d736f0de2
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
