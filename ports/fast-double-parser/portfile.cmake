vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lemire/fast_double_parser
    REF "v${VERSION}"
    SHA512 41115f3c3b77ad430b0b4a1e622dd2a911ce3283bfd4190b5081f368cd1c371c68cf49789a12a2ed610a91e5b4693fe0b9b0d07876e82cfb0b106a6bc33dedd0
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

file(INSTALL "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
