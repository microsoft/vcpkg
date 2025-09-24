# Fetch source from GitHub
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Nouridin/cconfig
    REF "v${VERSION}"  # e.g., v1.0.0
    SHA512 8CE0C0FCA4E55AF9CFD56BA7779F4775703752D328518FE72F242336A7D4DB08B53284CA6148FC65BDBFE7D5BE4F025F49DFC7B13A45E2B69F350E15966C1929
)

# Copy header to include/cconfig/
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include/cconfig")
file(COPY "${SOURCE_PATH}/cconfig.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/cconfig")

# Install license correctly for vcpkg
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Optional: remove auto-generated usage folder if exists
if(EXISTS "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage")
endif()

# Skip copyright and post-build checks for header-only
