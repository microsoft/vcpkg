vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skypjack/entt
    REF "v${VERSION}"
    SHA512 65064199790e5ba69ef01188ce04105e5d8ad673de253e6247dd4b26a394b115cc4030e7f87285fb7e63d72f28c0be3a05ad286585ded0bb2229b47268159a39
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
