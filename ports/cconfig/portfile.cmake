vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Nouridin/cconfig
    REF "v${VERSION}" # e.g., v1.0.0
    SHA512 8CE0C0FCA4E55AF9CFD56BA7779F4775703752D328518FE72F242336A7D4DB08B53284CA6148FC65BDBFE7D5BE4F025F49DFC7B13A45E2B69F350E15966C1929
    HEAD_REF main
)

# Copy the main header
file(COPY "${SOURCE_PATH}/cconfig.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/cconfig")

# Convenience header in root include folder
file(WRITE "${CURRENT_PACKAGES_DIR}/include/cconfig.h" "#include \"cconfig/cconfig.h\"\n")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Remove auto-generated usage file if present
file(REMOVE "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage")

# Add a minimal test to ensure the package is usable
vcpkg_test_cmake(TEST_ROOT_DIR "${CURRENT_PORT_DIR}")
