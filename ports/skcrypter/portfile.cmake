vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skadro-official/skCrypter
    REF 7970de8acc01af5ecef044374c26ecb33b7cd069
    SHA512 f0ef3c6673523d5b86bc9b5859ae77fb4d182238b67ce4f07da1068f23ee7915e028ed837b8c6b2dd5421ae5a7c043e0d486d18c4b5404ebee50bd8cef4ba4bb
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/files/skCrypter.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)