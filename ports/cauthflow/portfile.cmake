vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            offscale/cauthflow
    REF             8b02b21bd915520c1b037573491c44c78891d0f4
    SHA512          2f980ade9883cd5d3b527a47bc2658af3ce15690fcf72413bfa30c8bd31331f8ffce0e383c53f699a41df5ee2bf3a0b49c9f6d37518a5b1f4602a36a5a991a62
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
