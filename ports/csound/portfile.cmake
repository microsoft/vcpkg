vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO csound/csound
    REF 6.18.1
    SHA512 4ea4dccb36017c96482389a8d139f6f55c79c5ceb9cc34e6d2bfabcb930b4833d0301be4a4b21929db27b2d8ce30754b5c5867acd2ea5a849135e1b8d1506acf
    PATCHES 
        "use_after_free.patch"
        "misleading_indentation.patch"
        "incompatible_pointer_types.patch"
        "format_truncation.patch"
        "error_address.patch"
        "permission_denied.patch"
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/csound" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")