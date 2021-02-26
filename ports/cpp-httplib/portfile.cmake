# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-httplib
    REF 40db42108f4303057a0494710ab06c796bb60448 # v0.7.18
    SHA512 54f5d7b4f8b9824977ceed4681db5af4421c26d6f07d6085428e4fa17007c2c1cde4c32615bc4100ce8fd9fb449ab420e94f057be4db7140479578654d1e6941
    HEAD_REF master
)

file(
    COPY ${SOURCE_PATH}/httplib.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
