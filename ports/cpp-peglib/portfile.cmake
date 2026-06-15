#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-peglib
    REF "v${VERSION}"
    SHA512 22c55acd1dbebab6c9fc7b9df901f7e2f0328c0bef5cdda24d30c364597a58d0565b692f3ed9c6128c7be7397d900fc26b97b9339456021390b5130ae720cfc4
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/peglib.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/cpp-peglib" RENAME copyright)
