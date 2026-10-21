vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lieff/minimp3
    REF ea99364f61c14656440e8d77e9c233ccf3124633 # committed on 2026-07-27
    SHA512 f05e513ccc2b4111609800676efe618addf7cbb82a91e69c8a6e5599e5b49cfcb225050b33eec39211eac35e2060b94a48d15af4db72546cacc1dfc916362dbc
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/minimp3.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(COPY "${SOURCE_PATH}/minimp3_ex.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
