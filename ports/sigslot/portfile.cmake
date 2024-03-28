string(REPLACE "." "-" MINUS_VERSION "${VERSION}")
vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sigslot/sigslot
    REF "${VERSION}"
    FILENAME "sigslot-${MINUS_VERSION}.tar.gz"
    SHA512 0
)

file(INSTALL ${SOURCE_PATH}/sigslot.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL ${CURRENT_PORT_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
