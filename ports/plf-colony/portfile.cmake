# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_colony
    REF 7eceefdd9291103dcee2d6c5fae6b63da1855dc5
    SHA512 3856608d7129c832739562d86711a25a7e180b603ed652b01925e07d94538ad6290c597274ee758b6c8ded65eae02fd7bac416811f21480549416646ffb27b63
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/plf_colony.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
