vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Arp1it/Minecraft_Server_Status_CPP
    REF v1.0.0
    SHA512 5b63ad7747f6b2b052120236758f272abadf8a45dc79098201c347cdec5c3e8a1874e5d201183b238b9c8528916db21cf8767d68b1b1023aa75d336c7f116096
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "minecraft-server-status"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/License"
)