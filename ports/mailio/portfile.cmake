vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO karastojko/mailio
    REF 1872f29d88a52f06cd96b611673b2e46c6b9832b # version_0-20-0
    SHA512 1686e49ed2c7163c33f88c820633e772986ecfea5696b78a44b370f44051190b14a1ddcd055bce2a9104324c80e8045cf0441c085eb6f272261da7e80bc4fdb5
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)
vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/mailio RENAME copyright)
