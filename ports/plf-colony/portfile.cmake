# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_colony
    REF 394c787ecf5a541b66d08b90f22cebc954f0599c
    SHA512 1b452e64b5c029545aa10a1aa1bfe913ce0df798546b31dc04a9677809a3ad4f212e65a8829c5055027a7416bcd82126b974f9cc0ad0561596e6d3253ee42ad2
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/plf_colony.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
