vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapbox/earcut.hpp
    REF "v${VERSION}"
    SHA512 87f52bf99273dc47f78ebacd4ee0ccbab4edd3f9b85d97aed1c0d1165b3e2523e1a71f3a37a118e82170e79d57a2e09644d4115facb63dc6f704affb9c428e6b
    HEAD_REF master
)

# This is a header only library
file(INSTALL "${SOURCE_PATH}/include/mapbox/earcut.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mapbox")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
