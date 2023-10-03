vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/extra-cmake-modules
    REF "v${VERSION}"
    SHA512 fc0c6e323fcc8862c4e093ced9571647108708fbdab474ef34dbc751ac5373d9b107bec53e56e09ede62dc56b36dad096d55f08f03f1f29f634219347df7d06f
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_HTML_DOCS=OFF
        -DBUILD_MAN_DOCS=OFF
        -DBUILD_QTHELP_DOCS=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

# Remove debug files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(COPY "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING-CMAKE-SCRIPTS" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

