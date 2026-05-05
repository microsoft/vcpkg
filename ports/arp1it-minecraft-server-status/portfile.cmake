vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Arp1it/Minecraft_Server_Status_CPP
    REF v1.0.0
    SHA512 5b63ad7747f6b2b052120236758f272abadf8a45dc79098201c347cdec5c3e8a1874e5d201183b238b9c8528916db21cf8767d68b1b1023aa75d336c7f116096
    HEAD_REF main
)

file(INSTALL
    "${SOURCE_PATH}/include/"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/License"
)
