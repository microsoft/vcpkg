vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-unicodelib
    REF f18fbc3ac3108f132fa25eea0ad130fb10d80da0 # committed on 2025-12-05
    SHA512 606ac1f6ea36aaf0133190ae0d2f8d2745c2c7ffdcf1461900960e4e0bc0bc8eaf8653f47e4b7656516d3d25c5b0912e84e98f9e578e20f0c8df8d68296e95cc
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/unicode.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
