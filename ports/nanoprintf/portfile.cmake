# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO charlesnicholson/nanoprintf
    REF "v${VERSION}"
    SHA512 a82da24fcd176c385c8c2d1666416bcbafc3bf3e1b9e1365c8ffd7a0158485c7af6b0dbf7cd0821a7af55238784cd682a0f22fe37527b91ea3f3eaa702c61c46
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/nanoprintf.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
