vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skypjack/entt
    REF "v${VERSION}"
    SHA512 440aa2a4aaef77271874e85a1804c867dfbe0aa31373dc754635fa6365682b3246e40765749e02cd56b7743eeae262eb2952185081a70eb92ce631f4626faf93
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENTT_BUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/EnTT/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Install natvis files
file(INSTALL "${SOURCE_PATH}/natvis/entt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/natvis")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
