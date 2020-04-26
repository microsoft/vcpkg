vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/restinio
    REF d170b6af5aacfc64d0ed25b4e25c5057d5dd2130 # v.0.6.6
    SHA512 017aeadd8b4171d7e7e11d631eb5b57d75272456948808e7dc8b988cba3cfbbd18cba5a95deccb7440bc4918f6daf17904358179f45a5158cf1b9ca687afc0c8
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/vcpkg
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/restinio)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
