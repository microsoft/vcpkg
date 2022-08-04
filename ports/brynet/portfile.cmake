#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO IronsDu/brynet
    REF 4739b5409ce1c9df055ae77f76fb055ca58b34da # v1.12.1
    SHA512  66f06cd6de9e516df7cadeb3b525ca74a8a9747840149686250e54dd4d8c044f6031fcefe9ca392f939f68fda821f6bcebd3a797ca1da11d34405d0a87ebae88
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/brynet DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
