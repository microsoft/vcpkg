vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tcbrindle/span
    REF 836dc6a0efd9849cb194e88e4aa2387436bb079b # master commit 2022-06-15
    SHA512 2ab1dfd976c5411231cfe7ec971c37e0d0b321e4470bd9b2b350f79deb4428c112a6244315712724e3953be2be2251ca4f1ac13dcd7e7a5f05898523c45e6686
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
