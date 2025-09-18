vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/extra-cmake-modules
    REF "v${VERSION}"
    SHA512 8bcb1b4f91aef3939d038c9d654b51d9311d047a2390d40e6942cc36fe1ee922f4073f6096120ede3afb5ff2c28865ba37025d0c93b46fb68896ca9fceac4995    
    HEAD_REF master
    PATCHES
        fix_generateqmltypes.patch # https://invent.kde.org/frameworks/extra-cmake-modules/-/merge_requests/201
        fix-wrong-version.patch
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

vcpkg_cmake_config_fixup(CONFIG_PATH share/ECM/cmake)

# Remove debug files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(COPY "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING-CMAKE-SCRIPTS")

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
