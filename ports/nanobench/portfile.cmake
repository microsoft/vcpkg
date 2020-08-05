# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinus/nanobench
    REF c534992696b9341274c6714931d0064d74239fcb #v4.0.0
    SHA512 09078f1100c6f843e7646b8aaab687c32e71ba2dc05a2a5b282c72ab064ceffbf4aeb5ad14c4a2bdbe2ea66dca9cd207dee5eade44f77844cddfa490b4c09c32
    HEAD_REF master
)

file(
    COPY ${SOURCE_PATH}/src/include/nanobench.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
