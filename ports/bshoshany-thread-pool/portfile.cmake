#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bshoshany/thread-pool
    REF v1.9
    SHA512 d87c67218a5373181332caa53aa611b79345df56fe2ba1452dbd552ef43fdeecbf2f6347f86c4730423c1545b4dc45524a4737949359cdda5ff911ce647eb8f4
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
