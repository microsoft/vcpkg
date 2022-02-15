#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bshoshany/thread-pool
    REF v2.0.0
    SHA512 eac1674ea999d25d8d0b8f1b24714830330ba4d345e3f730e49359bae89d9259e429d48357a45f7b4355cbbe1a63f04e7fe2c4e0be08b3bbea51018c62721fcc
    HEAD_REF master
)

# Install headers (header-only):
file(GLOB HEADER_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/*.hpp")
file(INSTALL
    "${HEADER_FILES}"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"

)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
