vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Cyan4973/xxHash
    REF 94e5f23e736f2bb67ebdf90727353e65344f9fc0 # v0.8.0
    SHA512 367c82b37fd188890574446a7c237294a4a9ba038aff9a19a5d5d119058df74c089c682e9abad3281d5e14020c08834666343b2ea18378f400c8a0ee640098b8
    HEAD_REF dev
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/cmake_unofficial
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/xxHash TARGET_PATH share/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
