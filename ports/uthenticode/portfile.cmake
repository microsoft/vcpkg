vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO trailofbits/uthenticode
    REF v1.0.0
    SHA512 3e7d681ae290ecec220769dd7b2956059088747273ada520525f096a292371998d6c252a914a91bce9ceaa7a3a597af686396d8337202aac34446ab1ad7e00da
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/uthenticode TARGET_PATH share/uthenticode)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(
    INSTALL
    "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/uthenticode"
    RENAME copyright
)
