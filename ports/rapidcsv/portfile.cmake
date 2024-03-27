vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO d99kris/rapidcsv
    REF "v${VERSION}"
    SHA512 cf1d8b9b23c03702496e63aedbc97cc1cbb64ca25bfd5a47a5fde5db80f5b1072a658b0b629a2e1c334e6d12c4511401f3e0aaef14843b1bce71a27c138ddba4
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
