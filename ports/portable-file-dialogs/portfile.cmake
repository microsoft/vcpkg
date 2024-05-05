# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO samhocevar/portable-file-dialogs
    REF "${VERSION}"
    SHA512 8f3f59534024357b1d4b9054f20f482bfb159c1666be1695220c1be8f028be6adac0d9d82aad7230922a5eea5971c051a8699e60bc99207813776f35ce6937b6
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/portable-file-dialogs.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
