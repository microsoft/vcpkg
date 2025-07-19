vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/extra-cmake-modules
    REF "v${VERSION}"
    SHA512 30a98c090b24ffabd63f687abcc6c9ca6153348772674cc09f1507a6ebd009ae85e3f79587024f20a12ac8731d8795404ad06f7536a19e0fb88b64f21c15781e
    HEAD_REF master
    PATCHES
        fix_generateqmltypes.patch # https://invent.kde.org/frameworks/extra-cmake-modules/-/merge_requests/201
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
