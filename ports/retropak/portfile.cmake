# This portfile is for reference when submitting to the vcpkg registry
# It should be placed in the vcpkg/ports/retropak directory

# This is a data-only package (schemas and locales)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO piersroberts/retropak
    REF v${VERSION}
    SHA512 e8a709af428222c40f75a5d0b12a9d70a34562ebc717a9702111a33251be57f042a78d5dbd84e1857c890e91426c925bb54e11b5ec275311288a2610e86d4c46
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/packages/vcpkg"
)

vcpkg_cmake_install()

# Remove empty directories
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Copy usage file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

