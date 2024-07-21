vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fix8mt/conjure_enum
    REF "v${VERSION}"
    SHA512 65fc1bc0364c6129b3b463b18c03ab38793c9632d0ece5b5e696a661e5ddad859c6b6ff2c5d8a1da98c7de2248e80f246e0a039d9e7be5fb507a4b61c71f69e8
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/fix8/conjure_enum.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
