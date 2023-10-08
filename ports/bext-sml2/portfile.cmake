# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boost-ext/sml2
    REF 6989e01776ab0d51a7b9463c307855d4a274888f
    SHA512 215e404769b80da01735d4038ec8fd63804ef3dfb6b65fcbce38b9e90491d4758c28338a1d259776b2258e35f14a4fb27330fa730800cf7289d147cf5e580d4e
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/sml2"
  DESTINATION "${CURRENT_PACKAGES_DIR}/include/boost"
)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
