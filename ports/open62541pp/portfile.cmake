vcpkg_download_distfile(REPLACE_INTERNAL_ADD_NODE_PATCH
    URLS https://github.com/open62541pp/open62541pp/commit/a4adbf3b3837d1206fa920fb2ce0759ba835749f.patch?full_index=1
    FILENAME open62541pp-replace-internal-add-node-a4adbf3b.patch
    SHA512 ab99735e019723cbc54726e46244878bb89319630b2843ac2668e2f5af12bd862fcb9a1ea5e6a671f2562efca50343208ea276e406fae287e20efb45961e8908
)
vcpkg_download_distfile(FIX_VERSION_MACROS_PATCH
    URLS https://github.com/open62541pp/open62541pp/commit/b3156a0dba8e060ed1a9e3c62c0a5602624d9b66.patch?full_index=1
    FILENAME open62541pp-fix-version-macros-b3156a0d.patch
    SHA512 03954e8a3a2fb7e669387966ed81bd73f70fe143c3541aded83141fee1230297f0f1be6bdaa7617f8a322762e28fefdb161378d5a44a3464d32bb491c72a6b98
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open62541pp/open62541pp
    REF "v${VERSION}"
    SHA512 1d342df92eb4b09e139b9e653a45b797591e1f472cd3f9fdae7153acf396658dc95bdf6d7274dd02f144d4a0b175031a0fbc05a94f42d5ce757a783db361d68f
    HEAD_REF master
    PATCHES
        "${REPLACE_INTERNAL_ADD_NODE_PATCH}" # https://github.com/open62541pp/open62541pp/pull/721
        "${FIX_VERSION_MACROS_PATCH}" # https://github.com/open62541pp/open62541pp/pull/732
        open62541-1.5.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUAPP_BUILD_DOCUMENTATION=OFF
        -DUAPP_INTERNAL_OPEN62541=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
