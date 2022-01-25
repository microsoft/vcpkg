# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_colony
    REF 7243b4601b5d7e989550c158a9918ea5a05feaf4
    SHA512 aaf898ac5a37720545a7b7226c8bd09be80dcdd03d9c77a2c64cfe0aedbb59ede4042001c616c4b5d29f13717ae5b637c0608d83819c2bceae5606c8555a64da
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/plf_colony.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
