vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sonodima/wmipp
    REF "v${VERSION}"
    SHA512 78635ec00928b5cb1fb5ab0001fa9a06f75a2a7e5f77dafb8bc77cf31f3ee2f642db08572d82ed39a09783a89d660bebc9b96f91d0926dbbb3109737d54f91e6
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/include/wmipp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
