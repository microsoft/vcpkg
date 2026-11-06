vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AndyTechnologies/tiny-crc32c
	REF v1.0.1
    SHA512 2f2033459b75d7fca35e849131098da127e75074aafed838dccf9f838cdb378dde0992e42a9cc52b3e8636b1d9b726f80a44e65a215f2e09b32e012d12b032ac
    HEAD_REF main
)

file(INSTALL
    "${SOURCE_PATH}/include/tiny_crc32.hpp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

file(INSTALL
    "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)
