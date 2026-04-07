# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_colony
    REF 9f3196a5d870907ace96f576e1f4ccb272efb281
    SHA512 bcf2a5403df29be1f47c4ac01e6db1f4a115a86d63a8e3bc4f4aadf2f70e7f0c373630e8fb87f8c5ff09d87822cdd44aedbd157d45e56415762735a4b3d45138
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/plf_colony.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
