vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/extra-cmake-modules
    REF v5.88.0
    SHA512 976c83b155c92bdab639752ad44046722dbc363b0341533a51b2123a36cdfb82b0ddefa4886e1def9b7f236b8569dc9f9c2b26c0ea83debb631e574d531c30df
    HEAD_REF master
    PATCHES
        fix_canberra.patch         # https://invent.kde.org/frameworks/extra-cmake-modules/-/merge_requests/187
        fix_libmount.patch         # https://invent.kde.org/frameworks/extra-cmake-modules/-/merge_requests/200
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

# Remove debug files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(COPY "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING-CMAKE-SCRIPTS" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
