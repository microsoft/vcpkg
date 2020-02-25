#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IronsDu/brynet
    REF v1.0.5
    SHA512 2c625a6dc6f7b1b578d74f97b0ccec90856caaedb0725db4c5892cfaa33e77cd502b01ee26b1789017c459f4b0a03eaf16ae859dc51ad4e6f362aca7c5833995
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/brynet DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
