vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mobius3/font-chef
    REF v1.1.0
    SHA512 3df1e31e4405bcbb05ffed8fe618eb953498389adef3d83d337ac570644008bee031e08cd64382443ad123c4abf7e0acca5e3e16288caf6225672d6796a9494f
    HEAD_REF master
    PATCHES
        disable-warnings-as-errors.patch # to workaround https://github.com/mobius3/font-chef/issues/3
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
