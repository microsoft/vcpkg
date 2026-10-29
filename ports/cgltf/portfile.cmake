# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jkuhlmann/cgltf
    REF "v${VERSION}"
    SHA512 9474b2ae79ac34015b21e4a20813bfc14ad037636304a28ce91011989202a11568b7f7201bca745701163e2c1077425065782a2aa265d53fe6edeb2e7d0e0b0a
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/cgltf.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/cgltf_write.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
