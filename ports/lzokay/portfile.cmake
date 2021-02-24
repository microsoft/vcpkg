vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jackoalan/lzokay
    REF 546a9695271e8a8b4711383f828172754fd825f2
    SHA512 b4e96183ea52dc5ba0d88b4b9b27baa2c3e2c540b1bfd50cf7a3c2569337fbe9d73dd9939cb456d5f7459df8e10d84677d40ee33f7d524f0f5f8a723d7a70583
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)