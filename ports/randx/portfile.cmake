vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lidaixingchen/RandX
    REF v${VERSION}
    SHA512 83e560b8c09fee334e7510c6bbac49fb49771eebd9e96e5b3a37aa5817093705db496b9f6e59a64ae9000ebec7c6bc69445ce4bf0a270a4d5819bac12c8a5f67
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME RandX CONFIG_PATH lib/cmake/RandX)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
