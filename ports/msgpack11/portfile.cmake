vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ar90n/msgpack11
    REF v0.0.10
    SHA512 7b90893f9cdec529789f6e75703f5945c6fc5c946b8708a7a2cb295faf4af111c8cc61265b636f385641031b85181929205be9c5d155f405909445dce85b4ce8
    HEAD_REF master
    PATCHES
        msvc.patch
        fix-additerator.patch
        disable-werror.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DMSGPACK11_BUILD_TESTS=OFF
        -DMSGPACK11_BUILD_EXAMPLES=OFF
)


vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
