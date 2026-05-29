# header-only library, no build
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO swenson/sort
    REF 5820a8094e4a2ae1c88ac8f8df7735c332ee62ff # accessed on 2023-06-26
    SHA512 fbe89ba5c5531f46250e2b8128ea5f1d7bac642a590a2f6e5f2cc3befa61f175b8f1fc28317377cde50357e8947ddc7ba8e0751437cf2c9fb91b7469511be15a
    FILE_DISAMBIGUATOR 2
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/sort.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
