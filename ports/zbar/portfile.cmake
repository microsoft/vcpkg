vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ZBar/ZBar
    REF xxx
    SHA512 xxx
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Ddiscreture_INSTALL_CMAKE_DIR=share
)

vcpkg_install_cmake()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug
    ${CURRENT_PACKAGES_DIR}/share/zbar-config-version.cmake)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/zbar
    RENAME copyright)