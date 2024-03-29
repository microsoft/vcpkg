vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bshoshany/thread-pool
    REF "v${VERSION}"
    SHA512 4908f00def23082e7ddc0b24a710e53b3fde51b02188e79cfcd9dabb22627ebd1b6e5b3c4bf1b366eae79660c26878cc034c171747c3d0b7ef8a98c85a77033b
    HEAD_REF master
)

file(GLOB HEADER_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/include/*.hpp")

file(INSTALL ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
