# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-httplib
    REF e1133a2dcb3436ac36c75452a569b609cdb58a0b # v0.7.15
    SHA512 b0ead7fa561f26ebbe407b57b5f96c5ccc76689af28aeb734bd035b373fd63dca0909ea36ef016e426cb068e8712ae361654480695688a5b3979fb0864cec82d
    HEAD_REF master
)

file(
    COPY ${SOURCE_PATH}/httplib.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
