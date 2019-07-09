#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/wil
    REF 8bfcc43efc91ec3a4d8dfa8fd74f4025bded363f
    SHA512 301bf129e064cf5de4b0d19cf5e35e195c68ecb8800df0334729083929b097f7d5d425437f7214aec1eb29f694c5613eb26332bc5a72fbaff37d9057f61c7692
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR})
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/wil RENAME copyright)