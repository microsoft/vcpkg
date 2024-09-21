vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Ybalrid/kissnet
    REF 12ea4c632cc719b608876bf1894ce96eea0a1174 # 2024-01-20
    SHA512 44f169c912cfa00bcc6132dfbd62a4d3d40bb70db92ba69b21a76e32eb8b4363f17c6eb1413974af55f4fcfbafbf32cc98e6ac147e46bad8cf7c691016a30bdb
    HEAD_REF master
)

# Install the header-only library
file(INSTALL "${SOURCE_PATH}/kissnet.hpp"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
