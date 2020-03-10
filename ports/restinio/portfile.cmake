vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/restinio
    REF 6934bd5a8ad707eb6a04894ec3bb198a39f447d9 # v.0.6.5
    SHA512 5a0228a7a0940f38429cd63368ee3dee72ff2bc9a019bb7b3c9e59314a8fd7afee555f10f9ec375dc7dda412bc6922f7f561fc54b6cf2b783b7db3dda0c2ae6b
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
