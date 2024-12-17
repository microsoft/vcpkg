vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PragmaTwice/protopuf
    REF "v${VERSION}"
    SHA512 c74bd2bc6090fb1b09d697ff1c082028cb3bacbe7f18bb93afe8b323f8f140a3b6d1c79ac41d54cd06eb1132d97ddc61e1dd6c2e658368ac08f80c414eb779fd
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
