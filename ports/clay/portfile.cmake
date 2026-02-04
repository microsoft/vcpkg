# header-only library
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nicbarker/clay
    REF "v${VERSION}"
    SHA512 f454940397653fbd845b05ad484405abf197c3063959fe7762d6bf94c94bc6e5046cedd2f80b52fc89cee4299567861c91b992539f9aa661b729a5a521719343
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/clay.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
