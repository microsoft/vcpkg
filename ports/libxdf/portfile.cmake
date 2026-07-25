vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xdf-modules/libxdf
    REF "v${VERSION}"
    SHA512 3a4304c2cdbb2c581dfdbfbf24ce6bd4c279acba555a6e47cec98908c2bf3a63c098c9419771295b96982d86dc2dc80bce95ca3b0eb9bd433a1ecada8eb07b5c
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DXDF_NO_SYSTEM_PUGIXML=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/THIRD-PARTY-NOTICES.md")
