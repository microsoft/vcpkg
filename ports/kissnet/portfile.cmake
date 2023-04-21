vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Ybalrid/kissnet
    REF 6c2bbbc1a114d83f11cea86d4370766ac12fbbd0 # 2022-10-18
    SHA512 40182631e1c32628380369b7f8ca4dbae2049b0c0480396efb6a8197cca5006c8b68bc64553182c129ef8366a52a2434fd4f134bf5ffa1c0303af80b2e2a8cee
    HEAD_REF master
)

# Install the header-only library
file(INSTALL "${SOURCE_PATH}/kissnet.hpp"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
