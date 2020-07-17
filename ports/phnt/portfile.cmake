#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO processhacker/phnt
    REF daab013f48e5a15ce05697857f4c449f20f1ba7d
    SHA512 2117154c0a6996b004a6a434ca9f9401f2b07e659292eb24b6783da13fb9f77fe1ffa08e7fe04c7ce3dfb824e3a6fc74a1951e858df0583a9ed37aa94339f84f
    HEAD_REF master
)

# Install headers
file(GLOB HEADER_FILES ${SOURCE_PATH}/*.h)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)