# Get source code:
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xkbcommon/libxkbcommon
    REF e3c3420a7146f4ea6225d6fb417baa05a79c8202 # v 0.10.0
    SHA512 58f6cce838084757e052d2c2bbf989409c950ab30d373eaf5fa782ab0ead85cf2b85e006aaa194306800d004d0bc96564667dc332c9762d203e1657bdc663336
    HEAD_REF master
)

vcpkg_configure_meson(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS 
            -Denable-wayland=false
            -Denable-docs=false
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

