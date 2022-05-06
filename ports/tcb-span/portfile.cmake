vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tcbrindle/span
    REF 427f6bd0bbf36ad46aec4d8bdd7760beeb10dd33 # master commit 2021-12-15
    SHA512 c775bd50bc68d98fcde5e99bb9b6594c8ac9ef15fa15efe89c253b4135df77d83e58743d3c7e90d3aff03429251497a7d56d1900f6e258416c0664a82326243c
    HEAD_REF master
)

# Just a single header
file(
    INSTALL "${SOURCE_PATH}/include/tcb/span.hpp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/tcb"
)

# Handle copyright
file(
    INSTALL "${SOURCE_PATH}/LICENSE_1_0.txt"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)
